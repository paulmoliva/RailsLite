require 'json'

class Session
  # find the cookie for this app
  # deserialize the cookie into a hash
  def initialize(req)
    @req = req
    # byebug
    cookie = req.cookies["_rails_lite_app"]
    if cookie
      @cookie_value = JSON.parse(cookie)
    else
      @cookie_value = {}
    end
  end

  def [](key)
    @cookie_value[key]
  end

  def []=(key, val)
    @cookie_value[key] = val
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
    res.set_cookie("_rails_lite_app", JSON.generate(@cookie_value))
    @session = @cookie_value
  end
end
