class PagesController < ApplicationController
  allow_unauthenticated_access only: %i[home puzzle]

  def home
  end

  def puzzle
  end
end
