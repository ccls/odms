class Numeric
#module NumericExtension

	#	The purpose of this is to provide a number to be used as the maximum
	#	on a chart.  Basically rounding up to different scales depending
	#	on how big the number is.
	def chart_round
		max = self * 1.1
		return 10 unless max > 0;	#	only happens in testing so far
		l = Math.log10(max).to_i	#	FYI could be 0 if max < 10
		l = l - 1
		(( max / 10**l ).to_i * 10**l).to_i
	end

	def to_ssn
		sprintf('%09d',self.to_s).to_ssn
	end

end
#Numeric.send(:include,NumericExtension)
