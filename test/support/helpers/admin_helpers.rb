module AdminHelpers
  def assert_follow_link(path)
    assert_select "a[href='#{path}']"
    get path
  end
end
