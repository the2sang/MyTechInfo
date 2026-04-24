#!/usr/bin/env python3
"""
HWPX 양식 채우기 스크립트
stdin: JSON { dept, written_date, work_name, datetime_str, content_html, extra_info }
stdout: binary HWPX bytes
"""
import sys, json, zipfile, io, random
from lxml import etree

HP  = "http://www.hancom.co.kr/hwpml/2011/paragraph"
NS  = {"hp": HP}

ROW_HEIGHT  = 1984   # 기본 행 높이 (약 7mm)
CELL_MARGIN = {"left": "510", "right": "510", "top": "141", "bottom": "141"}


# ── 헬퍼 ──────────────────────────────────────────────────────────────

def strip_html(html):
    if not html:
        return ""
    parser = etree.HTMLParser(encoding="utf-8")
    tree = etree.fromstring(html.encode("utf-8"), parser)
    return "".join(tree.itertext()).strip()

def remove_linesegarray(p_el):
    for child in list(p_el):
        if etree.QName(child.tag).localname == "linesegarray":
            p_el.remove(child)

def _tag(local):
    return f"{{{HP}}}{local}"

def _p(text="", char_pr="8", para_pr="0"):
    p = etree.Element(_tag("p"), id="0", paraPrIDRef=para_pr,
                      styleIDRef="0", pageBreak="0", columnBreak="0", merged="0")
    run = etree.SubElement(p, _tag("run"), charPrIDRef=char_pr)
    if text:
        t = etree.SubElement(run, _tag("t"))
        t.text = text
    return p

def _sublist(*children):
    sl = etree.Element(_tag("subList"), id="", textDirection="HORIZONTAL",
                       lineWrap="BREAK", vertAlign="CENTER",
                       linkListIDRef="0", linkListNextIDRef="0",
                       textWidth="0", textHeight="0",
                       hasTextRef="0", hasNumRef="0")
    for c in children:
        sl.append(c)
    return sl


# ── HTML → HWPX 변환 ─────────────────────────────────────────────────

def _make_table_xml(html_table, cell_width):
    """lxml HTML table 요소 → hp:tbl Element"""
    rows = html_table.findall(".//tr")
    if not rows:
        return None

    col_count = max(len(r.findall("th") + r.findall("td")) for r in rows)
    row_count  = len(rows)
    if col_count == 0:
        return None

    col_width   = cell_width // col_count
    total_width = col_width * col_count
    total_height = ROW_HEIGHT * row_count
    tbl_id = str(random.randint(100000000, 999999999))

    tbl = etree.Element(_tag("tbl"),
                        id=tbl_id, zOrder="0", numberingType="TABLE",
                        textWrap="TOP_AND_BOTTOM", textFlow="BOTH_SIDES",
                        lock="0", dropcapstyle="None", pageBreak="CELL",
                        repeatHeader="0",
                        rowCnt=str(row_count), colCnt=str(col_count),
                        cellSpacing="0", borderFillIDRef="3", noAdjust="0")

    etree.SubElement(tbl, _tag("sz"),
                     width=str(total_width), widthRelTo="ABSOLUTE",
                     height=str(total_height), heightRelTo="ABSOLUTE", protect="0")
    etree.SubElement(tbl, _tag("pos"),
                     treatAsChar="0", affectLSpacing="0", flowWithText="1",
                     allowOverlap="0", holdAnchorAndSO="0",
                     vertRelTo="PARA", horzRelTo="COLUMN",
                     vertAlign="TOP", horzAlign="LEFT",
                     vertOffset="0", horzOffset="0")
    etree.SubElement(tbl, _tag("outMargin"), left="0", right="0", top="141", bottom="141")
    etree.SubElement(tbl, _tag("inMargin"), **CELL_MARGIN)

    for r_idx, tr in enumerate(rows):
        cells = tr.findall("th") + tr.findall("td")
        tr_el = etree.SubElement(tbl, _tag("tr"))
        for c_idx, td in enumerate(cells):
            text = "".join(td.itertext()).strip()
            tc = etree.SubElement(tr_el, _tag("tc"),
                                  name="", header="0", hasMargin="0",
                                  protect="0", editable="0", dirty="0",
                                  borderFillIDRef="3")
            tc.append(_sublist(_p(text, char_pr="8")))
            etree.SubElement(tc, _tag("cellAddr"),
                             rowAddr=str(r_idx), colAddr=str(c_idx))
            etree.SubElement(tc, _tag("cellSpan"), rowSpan="1", colSpan="1")
            etree.SubElement(tc, _tag("cellSz"),
                             width=str(col_width), height=str(ROW_HEIGHT))
            etree.SubElement(tc, _tag("cellMargin"), **CELL_MARGIN)

    return tbl

def _table_paragraph(html_table, cell_width):
    """HTML table → hp:p (run 안에 hp:tbl 포함)"""
    tbl = _make_table_xml(html_table, cell_width)
    if tbl is None:
        return None
    p = etree.Element(_tag("p"), id="0", paraPrIDRef="0",
                      styleIDRef="0", pageBreak="0", columnBreak="0", merged="0")
    run = etree.SubElement(p, _tag("run"), charPrIDRef="8")
    run.append(tbl)
    etree.SubElement(run, _tag("t"))
    return p

def html_to_hwpx_paragraphs(html, cell_width=46590):
    """HTML 문자열 → [hp:p, ...] 목록. 테이블은 hp:tbl 포함 단락으로 변환."""
    if not html:
        return [_p()]

    parser = etree.HTMLParser(encoding="utf-8")
    doc    = etree.fromstring(html.encode("utf-8"), parser)
    body   = doc.find(".//body")
    if body is None:
        return [_p(strip_html(html))]

    result = []

    def walk(node):
        tag = node.tag if isinstance(node.tag, str) else None
        if tag == "table":
            p = _table_paragraph(node, cell_width)
            if p is not None:
                result.append(p)
            return  # 하위 순회 불필요
        if tag in ("thead", "tbody", "tfoot", "tr", "th", "td"):
            return  # table 하위는 table 처리에서 담당
        if tag == "br":
            result.append(_p())
            return
        if tag in ("ul", "ol"):
            for li in node.findall(".//li"):
                t = "".join(li.itertext()).strip()
                if t:
                    result.append(_p("• " + t))
            return
        if tag in ("p", "div", "h1", "h2", "h3", "h4", "h5", "h6", "span"):
            # 직접 자식 중 table이 있으면 분리 처리
            has_table = any(
                isinstance(c.tag, str) and c.tag == "table"
                for c in node
            )
            if has_table:
                for child in node:
                    walk(child)
            else:
                t = "".join(node.itertext()).strip()
                if t:
                    result.append(_p(t))
            return
        # 그 외 → 자식 순회
        for child in node:
            walk(child)

    for child in body:
        walk(child)

    return result if result else [_p()]


# ── 셀 설정 ──────────────────────────────────────────────────────────

def set_cell_text(root, row_addr, col_addr, text):
    xpath = f"//hp:tc[hp:cellAddr[@rowAddr='{row_addr}' and @colAddr='{col_addr}']]"
    cells = root.xpath(xpath, namespaces=NS)
    if not cells:
        return
    cell = cells[0]
    paragraphs = cell.findall(f".//{{{HP}}}p")

    target_p = None
    for p in paragraphs:
        for t_el in p.findall(f".//{{{HP}}}t"):
            if t_el.text and t_el.text.startswith("[") and t_el.text.endswith("]"):
                target_p = p
                break
        if target_p is not None:
            break
    if target_p is None:
        target_p = paragraphs[0] if paragraphs else None
    if target_p is None:
        return

    run = target_p.find(f"{{{HP}}}run")
    if run is None:
        return
    t = run.find(f"{{{HP}}}t")
    if t is None:
        t = etree.SubElement(run, f"{{{HP}}}t")
    t.text = text
    remove_linesegarray(target_p)

    for p in paragraphs:
        if p is target_p:
            continue
        for t_el in p.findall(f".//{{{HP}}}t"):
            if t_el.text and t_el.text.startswith("[") and t_el.text.endswith("]"):
                t_el.text = ""

def set_cell_html(root, row_addr, col_addr, html, cell_width=46590):
    """HTML 내용을 HWPX 단락(테이블 포함)으로 변환하여 셀에 삽입."""
    xpath = f"//hp:tc[hp:cellAddr[@rowAddr='{row_addr}' and @colAddr='{col_addr}']]"
    cells = root.xpath(xpath, namespaces=NS)
    if not cells:
        return
    cell  = cells[0]
    sublist = cell.find(f"{{{HP}}}subList")
    if sublist is None:
        return

    new_paragraphs = html_to_hwpx_paragraphs(html, cell_width)

    # subList 안의 기존 p 요소 모두 제거 후 새 단락 삽입
    for p in sublist.findall(f"{{{HP}}}p"):
        sublist.remove(p)
    for p in new_paragraphs:
        sublist.append(p)


# ── 메인 ─────────────────────────────────────────────────────────────

def main():
    data = json.loads(sys.stdin.read())

    template_path = data["template_path"]
    dept          = data["dept"]
    written_date  = data["written_date"]
    work_name     = data["work_name"]
    datetime_str  = data["datetime_str"]
    content_html  = data.get("content_html", "")
    extra_info    = data.get("extra_info", "")

    # 1: 템플릿 ZIP 로드
    entries = {}
    with zipfile.ZipFile(template_path, "r") as zf:
        for name in zf.namelist():
            entries[name] = zf.read(name)

    # 2: section0.xml 수정
    xml_bytes = entries["Contents/section0.xml"]
    root = etree.fromstring(xml_bytes)

    set_cell_text(root, 1, 1, dept)
    set_cell_text(root, 1, 3, written_date)
    set_cell_text(root, 2, 1, work_name)
    set_cell_text(root, 3, 1, datetime_str)
    set_cell_html(root, 4, 1, content_html)          # HTML → HWPX (테이블 포함)
    set_cell_text(root, 5, 1, extra_info.strip())

    tree = etree.ElementTree(root)
    buf  = io.BytesIO()
    tree.write(buf, xml_declaration=True, encoding="UTF-8", standalone=True)
    entries["Contents/section0.xml"] = buf.getvalue()

    # 3: HWPX 재패키징 → stdout binary
    out = io.BytesIO()
    with zipfile.ZipFile(out, "w") as zf:
        if "mimetype" in entries:
            zf.writestr(zipfile.ZipInfo("mimetype"), entries["mimetype"],
                        compress_type=zipfile.ZIP_STORED)
        for name, content in entries.items():
            if name == "mimetype":
                continue
            zf.writestr(name, content, compress_type=zipfile.ZIP_DEFLATED)

    sys.stdout.buffer.write(out.getvalue())

if __name__ == "__main__":
    main()
