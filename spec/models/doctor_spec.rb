require 'spec_helper'

describe Doctor do

	before do 
		@doctor = Doctor.new(name: "Example Doctor", email: "doctor@example.com") 
	end

	subject { @doctor }

	it { should respond_to(:name) }
	it { should respond_to(:email) }
	it { should respond_to(:password_digest) }

	it { should be_valid }

	describe "when name is not present" do
		before { @doctor.name = " " }
		it { should_not be_valid }
	end

	describe "when email is not present" do
		before { @doctor.email = " " }
		it { should_not be_valid }
	end

	describe "when doctor name is too long" do
		before { @doctor.name = "a" * 51 }
		it { should_not be_valid }
	end

	describe "when email format is invalid" do
		it "should be invalid" do
			addresses = %w[user@foo,com user_at_foo.org example.user@foo.
                     foo@bar_baz.com foo@bar+baz.com]
            addresses.each do |invalid_address|
            	@doctor.email = invalid_address
            	expect(@doctor).not_to be_valid
            end
        end
    end

    describe "when email format is valid" do
    	it "should be valid" do
    		addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
    		addresses.each do |valid_address|
    			@doctor.email = valid_address
    			expect(@doctor).to be_valid
    		end
    	end
    end

    describe "when email address is already taken" do
    	before do
    		doctor_with_same_email = @doctor.dup
    		doctor_with_same_email.email = @doctor.email.upcase
    		doctor_with_same_email.save
    	end

    	it { should_not be_valid }
    end
end
