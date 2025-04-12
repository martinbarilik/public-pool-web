# frozen_string_literal: true

require 'test_helper'

class UserTest < ActiveSupport::TestCase
	setup do
		@user = users(:one)
	end

	test 'has many workers' do
		assert_respond_to @user, :workers
		assert_kind_of ActiveRecord::Associations::CollectionProxy, @user.workers
	end

	test 'validates presence of name' do
		user = User.new
		assert_not user.valid?
		assert_includes user.errors[:name], "can't be blank"
	end

	test 'normalizes name' do
		user = User.create!(name: 'John Doe')
		assert_equal 'johndoe', user.name

		user.update!(name: 'Jane  Smith')
		assert_equal 'janesmith', user.name
	end

	test 'destroys associated workers' do
		# Clear any existing workers to ensure clean state
		@user.workers.destroy_all

		worker = @user.workers.create!(name: 'Test Worker')
		assert_difference 'Worker.count', -1 do
			@user.destroy
		end
		assert_not Worker.exists?(worker.id)
	end
end
