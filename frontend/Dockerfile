FROM nginx:alpine

COPY nginx.conf /etc/nginx/nginx.conf
COPY proxy_common.conf /etc/nginx/proxy_common.conf

CMD ["nginx", "-g", "daemon off;"]