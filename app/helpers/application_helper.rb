module ApplicationHelper
  def nav_link_to(name, options, html_options = {})
    url = url_for(options)
    class_list = [html_options.delete(:class), "menu-item"].compact

    selected = if html_options.key?(:match)
      _controller, _action = html_options[:match].split("#")
      params[:controller] == _controller &&
        (!_action || params[:action] == _action)
    end

    class_list << "selected" if selected

    link_to name, url, html_options.merge(class: class_list)
  end
end
