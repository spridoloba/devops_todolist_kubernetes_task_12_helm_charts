
run the bootstrap script to create the kind cluster, namespace, and deploy the Helm chart:

chmod +x bootstrap.sh
./bootstrap.sh

whis will:

create a kind cluster using cluster.yml
create the todoapp namespace

deploy the todoapp Helm chart (and MySQL subchart if present)

verify that all resources are running
check that all Pods, Deployments, and Services are up and running:


kubectl get all -n todoapp
Expected output example:

swift

NAME                                 READY   STATUS    RESTARTS   AGE
pod/todoapp-xxxxxx                   1/1     Running   0          1m
pod/todoapp-mysql-0                  1/1     Running   0          1m

NAME                 TYPE        CLUSTER-IP      PORT(S)    AGE
service/todoapp      ClusterIP   10.96.145.21    80/TCP     1m
service/todoapp-mysql  ClusterIP 10.96.170.54    3306/TCP   1m
If all Pods are in the Running state — the deployment was successful.

Validate application readiness and liveness
Check the application readiness endpoint (it should return Healthy):


kubectl port-forward svc/todoapp -n todoapp 8080:80 &
curl http://localhost:8080/readiness
Expected output:


Healthy
(Optional) You can also check the liveness endpoint:


curl http://localhost:8080/liveness
4. Verify MySQL connection
If your chart includes MySQL, verify that the database is reachable from inside the cluster:


kubectl exec -it -n todoapp svc/todoapp-mysql -- mysql -uapp_user -p1234 -e "SHOW DATABASES;"
Expected to see:


+--------------------+
| Database           |
+--------------------+
| app_db             |
| information_schema |
+--------------------+
5. Check logs
To confirm that the application is running properly and connected to the database:


kubectl logs -l app=todoapp -n todoapp