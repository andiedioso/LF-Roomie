=begin
MIT License

Copyright (c) 2019 cheskape, Bryzeeboy, andiedioso

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

This is a course requirement for CS 192 Software Engineering II under the
supervision of Asst. Prof. Ma. Rowena C. Solamo of the Department of
Computer Science, College of Engineering, University of the Philippines,
Diliman for the AY 2018-2019.

Code History:
01/31/19
    -file created from generating rails model User
    -added validation for username
    -used devise gem that added devise code
    -defined login
    -defined a function to be used for logging in by username, email, or mobile number
=end

class User < ApplicationRecord
    # Include default devise modules. Others available are:
    # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable

    validates :username, presence: :true, uniqueness: {case_sensitive: false}
    validates :mobile_number, presence: :true, uniqueness: {case_sensitive: false}

    #username may not use '@' symbol
    validates_format_of :username, with: /^[a-zA-Z0-9_\.]*$/, :multiline => true
    #mobile number format of 09XXXXXXXXX
    validates_format_of :mobile_number, with: /^(09\d{9,9})$/, :multiline => true

    devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :validatable

    attr_writer :login

    #access username, email, and mobile number from login
    def login
        @login || self.username || self.email || self.mobile_number
    end

    def self.find_for_database_authentication(warden_conditions)
        #duplicate warden conditions
        conditions = warden_conditions.dup
        #if the deleted login value is equal to login
        if login = conditions.delete(:login)
            #look for record and return the first record (username and email are case insensitive so use the lower function to make them all lowercase for checking)
            where(conditions).where(["lower(username) = lower(:value) OR mobile_number = :value OR lower(email) = lower(:value)", { :value => login }]).first
            #check if the hash has a username, email, or mobile number key
        elsif conditions.has_key?(:username) || conditions.has_key?(:email) || conditions.has_key?(:mobile_number)
            #get the first record in conditions and return its value
            where(conditions.to_h).first
        end
    end
end
