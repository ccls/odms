#	==	requires
#	*	path ( unique, > 1 char and starts with a / )
#	*	menu ( unique and > 3 chars )
#	*	title ( > 3 chars )
#	*	body ( > 3 chars )
#
#	==	scope(s)
#	*	not_home (returns those pages where path is not just '/')
#	*	roots
#
#	uses acts_as_list for parent / child relationship.  As this
#	is only a parent and child and no deeper, its ok.  If it
#	were to get any deeper, the list should probably be changed
#	to something like a nested set.
class Page < ActiveRecord::Base
#	default_scope :order => 'position ASC'
#	This is odd.
#	Create a page and it get position 1
#	Create another page and it get position 2
#	Create yet another page and it get position 2 also????
#	Create yet another page and it get position 2 also????
#	remove the default scope and it works.
#	I'm quickly learning that default scopes suck (in rails 3).

	acts_as_list :scope => :parent_id
#	acts_as_list :scope => "parent_id \#{(parent_id.nil?)?'IS NULL':'= parent_id'} AND locale = '\#{locale}'"

	validates_length_of :path,  :minimum => 1
	validates_format_of :path,  :with => /^\//, :allow_blank => true
	validates_length_of :menu_en, :title_en, :body_en, :minimum => 4
	validates_uniqueness_of :menu_en, :path

	belongs_to :parent, :class_name => 'Page'
	has_many :children, :class_name => 'Page', :foreign_key => 'parent_id',
		:dependent => :nullify
	
	scope :roots,    where(:parent_id => nil, :hide_menu => false)
	scope :hidden,   where(:hide_menu => true)
#	scope :not_home, where("path != '/'")
	scope :not_home, where(self.arel_table[:path].not_eq('/'))


	before_validation :adjust_path

	def to_s
		title
	end

	def adjust_path
		unless self.path.nil?
			#	remove any duplicate /'s
			self.path.gsub!(/\/+/,'/')
			self.path.downcase!
		end
	end

	#	scope ALWAYS return an "Array"
	#	so if ONLY want one, MUST use a method.
	#	by_path returns the one(max) page that
	#	matches the given path.
	def self.by_path(path)
		#	interesting.  limit 1 still returns an array
		where(:path => path.downcase ).limit(1).first
	end

	def root
		page = self
#	NOTE in theory, this could be an infinite loop.
		until page.parent == nil
			page = page.parent
		end 
		page
	end

	def is_home?
		self.path == "/"
	end

	def menu(locale='en')	#	sends session[:locale] which can be nil
		r = send("menu_#{locale||'en'}")
		( r.blank? ) ? send(:menu_en) : r
	end
	def menu=(new_menu)
		self.menu_en = new_menu
	end
	def title(locale='en')	#	sends session[:locale] which can be nil
		r = send("title_#{locale||'en'}")
		( r.blank? ) ? send(:title_en) : r
	end
	def title=(new_title)
		self.title_en = new_title
	end
	def body(locale='en')	#	sends session[:locale] which can be nil
		r = send("body_#{locale||'en'}")
		( r.blank? ) ? send(:body_en) : r
	end
	def body=(new_body)
		self.body_en = new_body
	end

end
