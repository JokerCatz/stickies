module Stickies
  module AccessHelpers
    ################################################################################
    # Add an error message.  See Stickies::Messages#add for full details.
    def error_stickie (message, options={})
      Stickies::Messages.error(session, message, options)
    end
    ################################################################################
    # Add a warning message.  See Stickies::Messages#add for full details.
    def warning_stickie (message, options={})
      Stickies::Messages.warning(session, message, options)
    end
    ################################################################################
    # Add a notice message.  See Stickies::Messages#add for full details.
    def notice_stickie (message, options={})
      Stickies::Messages.notice(session, message, options)
    end
    ################################################################################
    # Add a debug message.  See Stickies::Messages#add for full details.
    def debug_stickie (message, options={})
      Stickies::Messages.debug(session, message, options)
    end
    ################################################################################
    # Check to see if a message has been seen by the user.  See
    # Stickies::Messages#seen? for full details.
    def stickie_seen? (name, options={})
      Stickies::Messages.seen?(session, name, options)
    end
  end
end
################################################################################
