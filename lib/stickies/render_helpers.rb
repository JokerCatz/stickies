module Stickies
  module RenderHelpers
    ################################################################################
    # Render the stickie messages, returning the resulting HTML , map to jGrowl Options , Options:
    # for Globel use in render_stickies({})
    #
    # +closerTemplate+ [<div>"[ close all ]"</div>] This content is used for the close-all link that is added to the bottom of a jGrowl container when it contains more than one notification.
    # +debug_mode+ [false] debug mode for firebug
    #
    # for Sub stickies
    #
    # +header+ [""] Optional header to prefix the message, this is often helpful for associating messages to each other.
    # +sticky+ [false] When set to true a message will stick to the screen until it is intentionally closed by the user.
    # +glue+ ["after"] Designates whether a jGrowl notification should be appended to the container after all notifications, or whether it should be prepended to the container before all notifications. Options are after or before.
    # +position+ ["top-right"] Designates a class which is applied to the jGrowl container and controls it's position on the screen. By Default there are five options available, top-left, top-right, bottom-left, bottom-right, center. This must be changed in the defaults before the startup method is called.
    # +theme+ ["default"] A CSS class designating custom styling for this particular message.
    # +corners+ ["10"px] If the corners jQuery plugin is include this option specifies the curvature radius to be used for the notifications as they are created.
    # +check+ ["1000"] The frequency that jGrowl should check for messages to be scrubbed from the screen.
    # +life+ ["3000"] The lifespan of a non-sticky message on the screen.
    # +speed+ ["normal"] The animation speed used to open or close a notification.
    # +easing+ ["swing"] The easing method to be used with the animation for opening and closing a notification.
    # +closer+ [true] Whether or not the close-all button should be used when more then one notification appears on the screen. Optionally this property can be set to a function which will be used as a callback when the close all button is clicked.
    # +closeTemplate+ [&times;] This content is used for the individual notification close links that are added to the corner of a notification.
    # +log+ [function(e,m,o) {""}] Callback to be used before anything is done with the notification. This is intended to be used if the user would like to have some type of logging mechanism for all notifications passed to jGrowl. This callback receives the notification's DOM context, the notifications message and it's option object.
    # +beforeOpen+ [function(e,m,o) {""}] Callback to be used before a new notification is opened. This callback receives the notification's DOM context, the notifications message and it's option object.
    # +open+ [function(e,m,o) {""} Callback to be used when a new notification is opened. This callback receives the notification's DOM context, the notifications message and it's option object.
    # +beforeClose+ [function(e,m,o) {""}] Callback to be used before a new notification is closed. This callback receives the notification's DOM context, the notifications message and it's option object.
    # +close+ [function(e,m,o) {""}] Callback to be used when a new notification is closed. This callback receives the notification's DOM context, the notifications message and it's option object.
    # +animateOpen+ [{ "opacity": 'show' }] The animation properties to use when opening a new notification (default to fadeOut).
    # +animateClose+ [{ "opacity": 'hide' }] The animation properties to use when closing a new notification (defaults to fadeIn).
    ################################################################################
    STICKIES_JAVASCRIPT = {
      :header => ["header: \"" , "\","],
      :sticky => ["sticky: " , ","],
      :glue => ["glue: \"" , "\","],
      :position => ["position: \"" , "\","],
      :theme => ["theme: \"" , "\","],
      :corners => ["corners: \"" , "px\","],
      :check => ["check: " , ","],
      :life => ["life: " , ","],
      :speed => ["speed: \"" , "\","],
      :easing => ["easing: \"" , "\","],
      :closer => ["closer:" , ","],
      :closeTemplate => ["closeTemplate: \"" , "\","],
      :log => ['log: function(e,m,o) {' , '},'],
      :beforeOpen => ['beforeOpen: function(e,m,o) {' , '},'],
      :open => ['open: function(e,m,o) {' , '},'],
      :beforeClose => ['beforeClose: function(e,m,o) {' , '},'],
      :close => ['close: function(e,m,o) {' , '},'],
      :animateOpen => ['animateOpen: function(e,m,o) {' , '},'],
      :animateClose => ['animateClose: function(e,m,o) {' , '},'],
    }

    def render_stickies(configuration={})
      #init
      html = ""
      sub_html = ""
      #build
      Stickies::Messages.fetch(session, :stickies) do |messages|
        sub_html << render_stickies_separate(messages,configuration)
        messages.flash
      end
      #package
      if sub_html.length > 0
        html << %Q[
        <script type="text/javascript">
            (function($){
              $(document).ready(function(){
]
        #closer
        html << "                $.jGrowl.defaults.closer = function() {
                  console.log('+ (configuration[:closerTemplate] || \"[ close all ]\") +', this);
                };\n" unless configuration[:closerTemplate].nil?
        #firebug log
        html << "                $.jGrowl.defaults.log = function(e,m,o) {
                  $('#logs').append('<div><strong>#' + $(e).attr(\"id\") + '</strong><em>' + (new Date()).getTime() + '</em>: ' + m + ' (' + o.theme + ')</div>')
                };\n" unless configuration[:debug_mode].nil?
        #all
        html << sub_html
        #end
        html << %Q[              });
            })(jQuery);
        </script>]
      end
      return html
    end
    ################################################################################
    # Helper method to render each stickie message as a separate div.
    def render_stickies_separate(messages,configuration)
      html = ''
      messages.each do |message|
        sub_html = ''
        #insert
        message.options.each_key do |temp_config|
          #update for support all option
          temp_configuration = configuration.merge(message.options)
          sub_html << STICKIES_JAVASCRIPT[temp_config][0] + temp_configuration[temp_config].to_s + STICKIES_JAVASCRIPT[temp_config][1] if STICKIES_JAVASCRIPT.include?(temp_config)
        end
        #jGrowl start
        html << '                $.jGrowl("' + message.message.to_s.gsub(/\\/, '\&\&').gsub(/'/, "''")  + '", {'
        #fix hash end of javascript
        html << sub_html[0..(sub_html.length - 2)] if sub_html.length > 0
        #jGrowl end
        html << "});\n"
      end
      return html
    end
  end
end
