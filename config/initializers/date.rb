class Date
	def diff(other_date)

		#	What if other date isn't a date?

		d = HWIA.new

		if(( self - other_date ) > 0 )
			d[:relation] = 'after'
			a = self
			b = other_date
		else
			d[:relation] = 'before'
			a = other_date
			b = self
		end

		d[:years] = a.year - b.year
		d[:months] = a.month - b.month
		if d[:months] < 0
			d[:years] -= 1 
			d[:months] = 12 - d[:months].abs
		end
		d[:days] = a.day - b.day
		if d[:days] < 0
			d[:months] -= 1 
			d[:days] = Time.days_in_month(b.month,b.year) - d[:days].abs
		end
		d
	end
end
