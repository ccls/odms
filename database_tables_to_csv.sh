#!/usr/bin/env bash

echo "Table Name, Field, Type, Null, Key, Default, Human Description"

#	$1 is blank as the first character is a |
#	sadly, one of the types is decimal(8,2) which contains a comma
#		and therefore MUST be quoted otherwise won't be parsed correctly.

awk '
	BEGIN { FS="|"; OFS="," }
	( /^\s*$/ ) {	}
	( /^FYI/ ) { }
	( /^\+/ ) {	}
	( /^Table:/ ) { split($0,t,": "); tablename=t[2]	}
	( /Field/ ){ }
	( /schema_migrations/ ){ }
	( ( /^\|/ ) && ( $2 !~ /Field/ ) ){ 
		print tablename,$2,"\""$3"\"",$4,$5,$6,""
	}' database_tables | sed 's/ //g'

