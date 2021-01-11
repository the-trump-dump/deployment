rmq_id=$(kubectl  get pods | grep  rabbitmq | cut -f1 -d\ )
kubectl port-forward $rmq_id 15672 5672