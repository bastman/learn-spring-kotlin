# learn-spring-kotlin
- spring boot
- kotlin
- docker + docker-compose

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


    