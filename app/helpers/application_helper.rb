module ApplicationHelper
  def active_class(domain = "")
    if active_class?(domain)
      "active"
    else
      "not-active"
    end
  end

  private

  def active_class?(domain)
    params[:domain].to_s.downcase == domain
  end
end
