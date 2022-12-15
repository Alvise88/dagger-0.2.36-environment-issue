package ci

import (
	"dagger.io/dagger"
    "dagger.io/dagger/core"
    "universe.dagger.io/docker"
)

dagger.#Plan & {

	client: _

	// Input
	client: filesystem: ".": read: include: [
	    ".git",
        "**/*.go",
		"**/*.tmpl",
        "**/*.yaml",
        "**/*.toml",
        "**/*.json",
        "**/*.ndjson",
        "**/*.yamlint",
        "**/*.conf",
        "**/*.keep",
        "**/*.tmpl",
        "**/*.lua",
        "**/*.sh",
		"**/*.j2",
        "**/*.tf",
        "**/*.hcl",
        "go.mod",
        "go.sum",
        "Dockerfile"
    ]

	client: env: {
        FLAVOUR: string // it shows push only with build commented
		// FLAVOUR: "alpine" | "debian" // in this case the behavior is quite different
	}

	actions: {
		_source: client.filesystem.".".read.contents

        // start comment

        if client.env.FLAVOUR != _|_ &&  client.env.FLAVOUR == "debian" {
            build: docker.#Dockerfile & {
                // This is the Dockerfile context
                source: _source

                dockerfile: path: "Dockerfile"

                buildArg: FLAVOUR: "debian"
            }
        }

        if client.env.FLAVOUR != _|_ &&  client.env.FLAVOUR == "alpine" {
            build: docker.#Dockerfile & {
                // This is the Dockerfile context
                source: _source

                dockerfile: path: "Dockerfile"

                buildArg: FLAVOUR: "alpine"
            }
        }


        if client.env.FLAVOUR == _|_ {
            build: docker.#Dockerfile & {
                // This is the Dockerfile context
                source: _source

                dockerfile: path: "Dockerfile"

                buildArg: FLAVOUR: "alpine" // default
            }
        }

        // end comment


        if client.env.FLAVOUR != _|_ {
            push: core.#Nop & {
                input: _source
            }
        }

        if client.env.FLAVOUR == _|_ {
            push: core.#Nop & {
                input: _source
            }    
        }

    }
    
}