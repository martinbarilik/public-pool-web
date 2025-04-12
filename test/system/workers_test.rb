# frozen_string_literal: true

require 'application_system_test_case'

class WorkersTest < ApplicationSystemTestCase
	setup do
		@worker = workers(:one)
	end

	test 'visiting the index' do
		visit workers_url
		assert_selector 'h1', text: 'Workers'
	end

	test 'should create worker' do
		visit workers_url
		click_on 'New worker'

		click_on 'Create Worker'

		assert_text 'Worker was successfully created'
		click_on 'Back'
	end

	test 'should update Worker' do
		visit worker_url(@worker)
		click_on 'Edit this worker', match: :first

		click_on 'Update Worker'

		assert_text 'Worker was successfully updated'
		click_on 'Back'
	end

	test 'should destroy Worker' do
		visit worker_url(@worker)
		click_on 'Destroy this worker', match: :first

		assert_text 'Worker was successfully destroyed'
	end
end
