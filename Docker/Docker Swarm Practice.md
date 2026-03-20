
# Docker-in-Docker Swarm Lab  

This guide shows how to create a 3-node Docker Swarm cluster inside Docker containers on macOS or Linux for learning purposes, allowing you to practice Swarm commands without multiple VMs.

## 1. Create a Custom Network  
Create a custom bridge network so the nodes can communicate.

`docker network create --driver bridge swarm-net`

## 2. Create Docker-in-Docker Nodes  
Launch three containers in privileged mode so Docker can run inside them.

`docker run -d --privileged --name node1 --network swarm-net docker:dind`  
`docker run -d --privileged --name node2 --network swarm-net docker:dind`  
`docker run -d --privileged --name node3 --network swarm-net docker:dind`  

## 3. Test Connectivity (Optional)
Verify that the nodes can reach each other.

`docker exec -it node1 sh`  

*If ping is missing:*  
`apk add --no-cache iputils`  
`ping node2`  
`ping node3`  
`exit`  

## 4. Initialize Swarm Manager  
Retrieve the internal IP of node1 and initialize the cluster.

`NODE1_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' node1)`  
`docker exec -it node1 docker swarm init --advertise-addr $NODE1_IP`

## 5. Join Worker Nodes  
Retrieve the join token from the manager and join node2 and node3 to the cluster.

`TOKEN=$(docker exec -it node1 docker swarm join-token -q worker)`  
`docker exec -it node2 docker swarm join --token $TOKEN $NODE1_IP:2377`  
`docker exec -it node3 docker swarm join --token $TOKEN $NODE1_IP:2377`

## 6. Verify the Cluster  
Check the status of all nodes from the manager node.

`docker exec -it node1 docker node ls`
