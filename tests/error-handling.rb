# encoding: utf-8
# (c) 2016 Martin Poljak (martin@poljak.cz)

$:.push("../lib")
require "riot"

context "Middleware" do
    setup do
        require "fuga/sidekiq/middleware/error-handling"
        Fuga::Sidekiq::Middleware::ErrorHandling::new
    end

    
    asserts("#call assigns proper options for handled exception") do
        msg = {
            'retry' => 1,
            'dead' => true,
            'fuga_error_handling' => {
                'Exception' => {
                    'retry' => 10,
                    'dead' => false
                },
                'KeyError' => {
                    'retry' => 15,
                    'dead' => false
                }
            }
        }

        begin
            topic.call(nil, msg, nil) do
                raise KeyError::new
            end
        rescue Exception => e
            msg['retry'] == 15 and msg['dead'] == false
        end
    end

    asserts("#call ignores unhandled exception and uses default") do
        msg = {
            'retry' => 1,
            'dead' => true,
            'fuga_error_handling' => {
                'Exception' => {
                    'retry' => 10,
                    'dead' => false
                }
            }
        }

        begin
            topic.call(nil, msg, nil) do
                raise IOError::new
            end
        rescue Exception => e
            msg['retry'] == 1 and msg['dead'] == true
        end        
    end
end

context "Worker (mixin)" do
    setup do
        require "fuga/sidekiq/error-handling"
        require "sidekiq/worker"
        
        class Worker
            include Sidekiq::Worker
            include Fuga::Sidekiq::ErrorHandling

            fuga_error KeyError,
                :retry => 10, :dead => true
            fuga_error IOError,
                :retry => 5, :dead => false
        end

        Worker::new.sidekiq_options_hash['fuga_error_handling']
    end

    asserts("option sets") {
        topic.to_a
    }.size(2)
    
    asserts("option sets") {
        topic.keys
    }.equals(['KeyError', 'IOError'])
    
    asserts("option sets retry records") {
        topic.map { |k, v| v['retry'] }
    }.equals([10, 5])
    
    asserts("option sets dead records") {
        topic.map { |k, v| v['dead'] }
    }.equals([true, false])
end
