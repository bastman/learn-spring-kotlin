# learn-spring-kotlin
- spring boot
- kotlin
- docker + docker-compose
- kubernetes + minikube
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
- deploy to k8s (minikube)
    ```
        # you may need to $ docker login <REGISTRY_HOST>
        
        $ make app.deploy DEPLOY_CONCERN="dev" 
        $ make app.deploy DEPLOY_CONCERN="prod"                
    ```
   
# k8s: setup stack in minikube
    ```
        # you may need to $ docker login <REGISTRY_HOST>
        # minikube must be up
        
        # start minikube
        $ minkube start
        
        # create deployment
        $ make k8s.deployment.create DEPLOY_CONCERN="dev"
        $ make k8s.deployment.create DEPLOY_CONCERN="prod"    
            
        # apply deployment
        $ make k8s.deployment.apply DEPLOY_CONCERN="dev"
        $ make k8s.deployment.apply DEPLOY_CONCERN="prod"  
              
        # delete deployment
        $ make k8s.deployment.create DEPLOY_CONCERN="dev"
        $ make k8s.deployment.create DEPLOY_CONCERN="prod"       
                                
    ```
   
## k8s: working with minikube and kubectl
```
        required version: 
        - minikube >= v0.24.0
        - kubectl >= v1.8.4        
``` 


```
        # show outdated casks
        
        # install vagrant
        $ brew cask install virtualbox
        
        # install minikube
        $ brew cask install minikube
        $ minikube version
        
        # re-install minikube (if outdated)
        $ brew cask reinstall minikube
        
        # start, stop, delete minikube
        $ minikube start
        $ minikube stop
        $ minikube delete
        
        
        # install kubectl
        $ brew install kubectl
        $ brew upgrade kubectl
        
        # kubectl use context "minikube"
        
        $ kubectl config use-context minikube
        $ kubectl config current-context
        $ kubectl cluster-info
        $ kubectl get nodes
       
``` 
      
