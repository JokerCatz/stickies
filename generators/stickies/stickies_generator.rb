class StickiesGenerator < Rails::Generator::Base
  ################################################################################
  def manifest
    record do |m|
      m.template('stickies.css', 'public/stylesheets/stickies.css')
      m.template('jquery.jgrowl.js', 'public/javascripts/jquery.jgrowl.js')
    end
  end
end
################################################################################
