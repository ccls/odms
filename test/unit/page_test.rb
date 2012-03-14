require 'test_helper'

class PageTest < ActiveSupport::TestCase

	assert_should_create_default_object

#	assert_should_require(:path,:menu_en,:title_en,:body_en)
#	assert_should_require_unique(:path,:menu_en)

	attributes = %w( path menu_en title_en body_en menu_es title_es body_es)
	required   = %w( path menu_en title_en body_en )
	unique     = %w( path menu_en )
	assert_should_require( required )
	assert_should_require_unique( unique )
	assert_should_not_require( attributes - required )
	assert_should_not_require_unique( attributes - unique )
	assert_should_not_protect( attributes )

	assert_should_require_attribute_length(:path,:minimum => 1)
	assert_should_require_attribute_length(:menu_en,:title_en,:body_en,
		:minimum => 4)

	test "should create page" do
		assert_difference 'Page.count' do
			page = Factory(:page)
			assert !page.new_record?, 
				"#{page.errors.full_messages.to_sentence}"
		end
	end

	test "should require path begin with slash" do
		assert_no_difference 'Page.count' do
			page = Factory.build(:page, :path => 'Hey')
			page.save
			assert page.errors.on(:path)
		end
	end

	test "should filter out multiple continguous slashes" do
		page = Factory(:page, :path => "///a//b///c" )
		assert_equal "/a/b/c", page.path
	end

	test "should downcase path" do
		page = Factory(:page, :path => "/A/B/C")
		assert_equal "/a/b/c", page.path
	end

	test "can have a parent" do
		parent = Factory(:page)
		page = Factory(:page, :parent_id => parent.id )
		assert_equal page.reload.parent, parent
	end

	test "should return self as root with no parent" do
		page = Factory(:page)
		assert_equal page, page.root
	end

	test "should return parent as root with parent" do
		parent = Factory(:page)
		page = Factory(:page, :parent_id => parent.id )
		assert_equal parent, page.reload.root
	end

	test "should nullify parent_id of children when parent destroyed" do
		parent = Factory(:page)
		child  = Factory(:page, :parent_id => parent.id )
		assert_equal child.reload.parent_id, parent.id
		parent.destroy
		assert_nil child.reload.parent_id
	end

	test "should return false if page is not home" do
		page = Factory(:page)
		assert !page.is_home?
	end

	test "should return true if page is home" do
		#	fixtures already contain a '/' page so won't be able to save
		page = Factory.build(:page, :path => '/')
		assert page.is_home?
	end

	test "should create page with hide_menu true" do
		assert_difference('Page.count',1){
		assert_difference('Page.roots.count',0){
			page = Factory(:page, :hide_menu => true)
#			assert_equal 1, Page.count
#			assert_equal 0, Page.roots.count
			assert_not_nil Page.find(page)
			assert_not_nil Page.find(page.id)
			assert_not_nil Page.find_by_path(page.path)
		} }
	end

	test "should find page by path" do
		p = Factory(:page)
		page = Page.by_path(p.path)
		assert_equal p, page
	end

	test "should assign menu_en on menu=" do
		p = Factory(:page)
		p.menu = 'My New Menu'
		assert_equal p.menu_en, 'My New Menu'
	end

	test "should assign title_en on title=" do
		p = Factory(:page)
		p.title = 'My New Title'
		assert_equal p.title_en, 'My New Title'
	end

	test "should assign body_en on body=" do
		p = Factory(:page)
		p.body = 'My New Body'
		assert_equal p.body_en, 'My New Body'
	end

	test "should return english menu without locale" do
		p = Factory(:page)
		assert_equal p.menu, p.menu_en
	end

	test "should return english title without locale" do
		p = Factory(:page)
		assert_equal p.title, p.title_en
	end

	test "should return english body without locale" do
		p = Factory(:page)
		assert_equal p.body, p.body_en
	end

	test "should return english menu with locale" do
		p = Factory(:page)
		assert_equal p.menu('en'), p.menu_en
	end

	test "should return english title with locale" do
		p = Factory(:page)
		assert_equal p.title('en'), p.title_en
	end

	test "should return english body with locale" do
		p = Factory(:page)
		assert_equal p.body('en'), p.body_en
	end

	test "should return spanish menu with locale" do
		p = Factory(:page, :menu_es => 'spanish menu')
		assert_equal p.menu('es'), p.menu_es
	end

	test "should return spanish title with locale" do
		p = Factory(:page, :title_es => 'spanish title')
		assert_equal p.title('es'), p.title_es
	end

	test "should return spanish body with locale" do
		p = Factory(:page, :body_es => 'spanish body')
		assert_equal p.body('es'), p.body_es
	end

	test "should return english menu with missing spanish locale" do
		p = Factory(:page, :menu_es => '')
		assert_equal p.menu('es'), p.menu_en
	end

	test "should return english title with missing spanish locale" do
		p = Factory(:page, :title_es => '')
		assert_equal p.title('es'), p.title_en
	end

	test "should return english body with missing spanish locale" do
		p = Factory(:page, :body_es => '')
		assert_equal p.body('es'), p.body_en
	end

end
