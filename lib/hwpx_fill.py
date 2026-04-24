#!/usr/bin/env python3
"""
HWPX 양식 채우기 스크립트 (new_hwpx_master.skill 기반)
stdin: JSON { dept, written_date, work_name, datetime_str, content_html, extra_info }
stdout: binary HWPX bytes
"""
import sys, os, json, zipfile, copy, io
from lxml import etree

def strip_html(html):
    if not html:
        return ""
    parser = etree.HTMLParser(encoding="utf-8")
    tree = etree.fromstring(html.encode("utf-8"), parser)
    return "".join(tree.itertext()).strip()

def remove_linesegarray(p_element):
    """★ 스킬 핵심 규칙: 수정된 <hp:p>에서 linesegarray 반드시 삭제"""
    HP = "http://www.hancom.co.kr/hwpml/2011/paragraph"
    for child in list(p_element):
        if etree.QName(child.tag).localname == "linesegarray":
            p_element.remove(child)

def set_cell_text(root, row_addr, col_addr, text):
    HP  = "http://www.hancom.co.kr/hwpml/2011/paragraph"
    ns  = {"hp": HP}
    xpath = f"//hp:tc[hp:cellAddr[@rowAddr='{row_addr}' and @colAddr='{col_addr}']]"
    cells = root.xpath(xpath, namespaces=ns)
    if not cells:
        return
    cell = cells[0]
    paragraphs = cell.findall(f".//{{{HP}}}p")

    # Find the paragraph that holds the placeholder text; fall back to first
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

    # Clear placeholder text from any other paragraphs in this cell
    for p in paragraphs:
        if p is target_p:
            continue
        for t_el in p.findall(f".//{{{HP}}}t"):
            if t_el.text and t_el.text.startswith("[") and t_el.text.endswith("]"):
                t_el.text = ""

def main():
    data = json.loads(sys.stdin.read())

    template_path = data["template_path"]
    dept          = data["dept"]
    written_date  = data["written_date"]
    work_name     = data["work_name"]
    datetime_str  = data["datetime_str"]
    content_html  = data.get("content_html", "")
    extra_info    = data.get("extra_info", "")

    plain = strip_html(content_html)

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
    set_cell_text(root, 4, 1, plain)
    set_cell_text(root, 5, 1, extra_info.strip())

    tree = etree.ElementTree(root)
    buf = io.BytesIO()
    tree.write(buf,
               xml_declaration=True,
               encoding="UTF-8",
               standalone=True)
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
