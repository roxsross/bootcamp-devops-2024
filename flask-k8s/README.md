# flask-k8s
Este ejemplo crea una API basica de `flask`, con un consumidor que accede desde el service a la API. 
Para exponer la API se creó un servicio tipo NodePort el cual expone un puerto en todos los nodos para que la API sea accesible desde fuera del cluster y por el consumer desde el nodo.


