require 'json'

class Flash
  def initialize(req)
    @req = req
    cookie = req.cookies["_rails_lite_app_flash"]
    if cookie
      @now = JSON.parse(cookie)
      @later = {}
    else
      @now = {}
      @later = {}
    end
  end

  def [](key)
    @now[key] || @later[key]
  end

  def []=(key, val)
    @later[key] = val
  end

  def now
    @now
  end


  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_flash(res)
    res.set_cookie("_rails_lite_app_flash", JSON.generate(@later))
  end
end
