# encoding: utf-8
# (c) 2016 Martin Poljak (martin@poljak.cz)

$:.push("../lib")
require "riot"

context "Middleware" do
    setup do
        require "fuga/sidekiq/middleware/job-status"
        Fuga::Sidekiq::Middleware::JobStatus::new
    end

    asserts("valid job should yield ['Processing', 'Completed']") do
        trace = [ ]
        Sidekiq.options[:fuga_job_status] = Proc::new do |worker, msg, status|
            trace << status
        end
        
        topic.call(nil, { }, nil) { }
        trace.length == 2 and trace == ['Processing', 'Completed']
    end

    asserts("invalid job should yield ['Processing', 'Failed']") do
        trace = [ ]
        Sidekiq.options[:fuga_job_status] = Proc::new do |worker, msg, status|
            trace << status
        end

        begin
            topic.call(nil, { }, nil) { raise Exception::new }
        rescue Exception => e
            trace.length == 2 and trace == ['Processing', 'Failed']
        end
    end
end
