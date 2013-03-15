class Hash
#module HashExtension	#	:nodoc:
#	def self.included(base)
#		base.instance_eval do
#			include InstanceMethods
#		end
#	end
#
#	module InstanceMethods

#	http://stackoverflow.com/questions/1766741/comparing-ruby-hashes
  def differences(other)
    (self.keys + other.keys).uniq.inject({}) do |memo, key|
      unless self[key] == other[key]
        if self[key].kind_of?(Hash) &&  other[key].kind_of?(Hash)
          memo[key] = self[key].diff(other[key])
        else
          memo[key] = [self[key], other[key]] 
        end
      end
      memo
    end
  end

		#	delete all keys matching the given regex
		#	and return the new hash
		def delete_keys_matching!(regex)
			self.keys.each do |k| 
				if k.to_s =~ Regexp.new(regex)
					self.delete(k)
				end 
			end 
			self
		end 

		#	delete all keys in the given array
		#	and return the new hash
		def delete_keys!(*keys)
			keys.each do |k| 
				self.delete(k)
			end 
			self
		end 

		#	params.dig('study_events',se.id.to_s,'eligible')
		def dig(*args)
			if args.length > 0 && self.keys.include?(args.first)
				key = args.shift
				if args.length > 0 
					if self[key].is_a?(Hash)
						self[key].dig(*args)
					else
						nil		#	This shouldn't ever happen
					end
				else
					self[key]
				end
			else
				nil
			end
		end

		#	from http://iain.nl/writing-yaml-files
		def deep_stringify_keys
			new_hash = {}
			self.each do |key, value|
				new_hash.merge!(key.to_s => ( value.is_a?(Hash) ? value.deep_stringify_keys : value ))
			end
			new_hash	#	originally didn't return new_hash, which didn't work for me.  returned self apparently.
		end

#	end

end
#Hash.send( :include, HashExtension )
