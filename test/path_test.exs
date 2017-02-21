defmodule PhoenixSwagger.PathTest do
  use ExUnit.Case
  use PhoenixSwagger

  doctest PhoenixSwagger.Path

  swagger_path :index do
    get "/api/v1/users"
    summary "Query for users"
    description "Query for users with paging and filtering"
    produces "application/json"
    tag "Users"
    operation_id "list_users"
    paging
    parameter "zipcode", :query, :string, "Address Zip Code", required: true, example: "90210"
    parameter "include", :query, :array, "Related resources to include in response",
                items: [type: :string, enum: [:organisation, :favourites, :purchases]],
                collectionFormat: :csv
    response 200, "OK", :Users, example: %{id: 1, name: "Joe", email: "joe@gmail.com"}
    response 400, "Client Error"
  end

  swagger_path :create do
    post "/api/v1/{team}/users"
    summary "Create a new user"
    consumes "application/json"
    produces "application/json"
    parameters do
      user :body, Schema.ref(:User), "user attributes"
      team :path, :string, "Users team ID"
    end
    response 200, "OK", user_schema()
  end

  def user_schema do
    swagger_schema do
      title "User"
      description "A user of the application"
      properties do
        name :string, "Users name", required: true
        id :string, "Unique identifier", required: true
        address :string, "Home adress"
      end
    end
  end

  test "swagger_path_index produces expected swagger json" do
    assert swagger_path_index() == %{
      "/api/v1/users" => %{
        "get" => %{
          "produces" => ["application/json"],
          "tags" => ["Users"],
          "operationId" => "list_users",
          "summary" => "Query for users",
          "description" => "Query for users with paging and filtering",
          "parameters" => [
            %{
              "description" => "Number of elements per page",
              "in" => "query",
              "name" => "page_size",
              "required" => false,
              "type" => "integer",
              "minimum" => 1
            },
            %{
              "description" => "Number of the page",
              "in" => "query",
              "name" => "page",
              "required" => false,
              "type" => "integer",
              "minimum" => 1
            },
            %{
              "description" => "Address Zip Code",
              "in" => "query",
              "name" => "zipcode",
              "required" => true,
              "type" => "string",
              "x-example" => "90210"
            },
            %{
              "collectionFormat" => "csv",
              "description" => "Related resources to include in response",
              "in" => "query",
              "items" => %{
                "type" => "string",
                "enum" => ["organisation", "favourites", "purchases"]
              },
              "name" => "include",
              "required" => false,
              "type" => "array"
            }
          ],
          "responses" => %{
            "200" => %{
              "description" => "OK",
              "schema" =>  %{
                "$ref" => "#/definitions/Users"
              },
              "examples" => %{
                "application/json" => %{
                  "email" => "joe@gmail.com",
                  "id" => 1,
                  "name" => "Joe"
                }
              }
            },
            "400" => %{
              "description" => "Client Error"
            }
          }
        }
      }
    }
  end

  test "swagger_path_create produces expected swagger json" do
    assert swagger_path_create() == %{
      "/api/v1/{team}/users" => %{
        "post" => %{
          "consumes" => ["application/json"],
          "description" => "",
          "operationId" => "PhoenixSwagger.PathTest.create",
          "parameters" => [
            %{
              "description" => "user attributes",
              "in" => "body",
              "name" => "user",
              "required" => false,
              "schema" => %{"$ref" => "#/definitions/User"},
            },
            %{
              "description" => "Users team ID",
              "in" => "path",
              "name" => "team",
              "required" => true,
              "type" => "string"
            }
          ],
          "produces" => ["application/json"],
          "responses" => %{
            "200" => %{
              "description" => "OK",
              "schema" => %{
                "type" => "object",
                "title" => "User",
                "description" => "A user of the application",
                "properties" => %{
                  "address" => %{
                    "description" => "Home adress",
                    "type" => "string"
                  },
                  "id" => %{
                    "description" => "Unique identifier",
                    "type" => "string"
                  },
                  "name" => %{
                    "description" => "Users name",
                    "type" => "string"
                  }
                },
                "required" => ["id", "name"]
              }
            }
          },
          "summary" => "Create a new user",
          "tags" => ["PathTest"]
        }
      }
    }
  end
end
