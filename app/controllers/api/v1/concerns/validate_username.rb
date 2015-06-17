module Api::V1::Concerns::ValidateUsername
  extend ActiveSupport::Concern

    def unique(username)
      user = User.find_by(username: username)
      if user.present?
        return false
      end
      return true
    end

    def check_username(username)
      if username =~ /^[A-Za-z0-9]+$/
        first_letter = username[0,1]
        if first_letter =~ /[[:alpha:]]/
          if username.length > 3
            if username.length < 25
              if username =~ /[[:digit:]]/
                last_letter = username[username.length-1, username.length-1]
                if last_letter =~ /[[:alpha:]]/
                  return false
                end
              end
              return true
            end
          end
        end
      end
      return false
    end

    def check_name(name)
      if name.length > 3
        if name.length < 25
          return true
        end
      end
      return false
    end
end
