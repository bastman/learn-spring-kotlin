# learn-spring-kotlin
- spring boot
- kotlin
- docker + docker-compose
- make

## project configuration:

- see: Makefile, manifest.json

## build and run 

- requirements
     ```
            # jq install
            $ make devtools.jq.brew
            
            # gradle install
            $ make devtools.gradle.brew
            
            # docker-toolbox install
            $ make devtools.docker.brew
     ```
    
- build
    ```
        # build jar + docker image
        $ make build
    ```
- run     
    ``` 
        # docker-compose up
        $ make up 
    ```
- stop     
    ```
        # docker-compose down
        $ make down         
    ```    

## ci
- requirements:
    ```
        you need create a docker repo
    
        e.g: docker.io/<USER>/repo-name
              
    ```    
- push to docker-registry
    ```
        # you may need to $ docker login <REGISTRY_HOST>
        $ make app.push         
    ```
- pull from docker-registry
    ```
        # you may need to $ docker login <REGISTRY_HOST>
        $ make app.pull         
    ```    