require 'spec_helper'
require 'stringio'
require 'gherkin/formatter/json_formatter'
require 'gherkin/formatter/model'

module Gherkin
  module Formatter
    describe JSONFormatter do
      it "renders results" do
        io = StringIO.new
        f = JSONFormatter.new(io)
        f.uri("f.feature")
        f.feature(Model::Feature.new([], [], "Feature", "ff", "", 1, "ff"))

        f.scenario(Model::Scenario.new([], [], "Scenario", "ss", "", 2, "ff/ss"))
          f.step(Model::Step.new([], "Given ", "g", 3, nil, nil))
            f.match(Model::Match.new([], "def.rb:33"))
            f.result(Model::Result.new(:passed, 1, nil))
          f.step(Model::Step.new([], "When ", "w", 4, nil, nil))
            f.match(Model::Match.new([], "def.rb:44"))
            f.result(Model::Result.new(:passed, 1, nil))
          f.hook('after', Model::Match.new([], "def.rb:55"), Model::Result.new(:passed, 22, nil))

#        f.scenario_outline(Model::ScenarioOutline.new([], [], "Scenario Outline", "so", "", 102, "ff/so"))
#          f.step(Model::Step.new([], "Given ", "a <foo> and <bar>", 103, nil, nil))
#          rows = []
#          rows << Model::ExamplesTableRow.new([], ["foo", "bar"], 105, 'ff/ex#105')
#          f.examples(Model::Examples.new([], [], "Examples", "ex", "", 104, "ff/ex", rows))

        f.eof
        f.done
        
        expected = %{
          [
            {
              "id": "ff",
              "uri": "f.feature",
              "keyword": "Feature",
              "name": "ff",
              "line": 1,
              "description": "",
              "elements": [
                {
                  "id": "ff/ss",
                  "keyword": "Scenario",
                  "name": "ss",
                  "line": 2,
                  "description": "",
                  "type": "scenario",
                  "steps": [
                    {
                      "keyword": "Given ",
                      "name": "g",
                      "line": 3,
                      "match": {
                        "location": "def.rb:33"
                      },
                      "result": {
                        "status": "passed",
                        "duration": 1
                      }
                    },
                    {
                      "keyword": "When ",
                      "name": "w",
                      "line": 4,
                      "match": {
                        "location": "def.rb:44"
                      },
                      "result": {
                        "status": "passed",
                        "duration": 1
                      }
                    }
                  ],
                  "hooks": [
                    {
                      "type": "after",
                      "match":{
                        "location":"def.rb:55"
                      },
                      "result":{
                        "status":"passed",
                        "duration": 22
                      }
                    }
                  ]
                }
              ]
            }
          ]
        }
        JSON.parse(expected).should == JSON.parse(io.string)
      end
    end
  end
end
