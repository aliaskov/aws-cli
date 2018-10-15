#!/bin/bash
#ECS_CLUSTER="google-analytics-ECSCluster-P3XRBDKY6WF1"
TASK_FAMILY="taskname-fargate"
ECS_SERVICE="taskname"
ECS_CLUSTER=`aws ecs list-clusters | grep ${ECS_SERVICE} |tr "/" " " | awk '{print $2}' | sed 's/"//' |  sed 's/,//'`


TASK_ID=`aws ecs list-tasks --cluster ${ECS_CLUSTER} --desired-status RUNNING --family ${TASK_FAMILY} | egrep "task" | tr "/" " " | tr "[" " " |  awk '{print $2}' | sed 's/"$//'`
TASK_REVISION=`aws ecs describe-task-definition --task-definition ${TASK_FAMILY} | egrep "revision" | tr "/" " " | awk '{print $2}' | sed 's/"$//'`

echo "cluster ${ECS_CLUSTER} , service ${ECS_SERVICE} , task-definition ${TASK_FAMILY}:${TASK_REVISION} , TASK_ID ${TASK_ID}"


aws ecs update-service --cluster ${ECS_CLUSTER} --service ${ECS_SERVICE} --task-definition ${TASK_FAMILY}:${TASK_REVISION} --desired-count 0
aws ecs stop-task --cluster ${ECS_CLUSTER} --task ${TASK_ID}

sleep 3
aws ecs update-service --cluster ${ECS_CLUSTER} --service ${ECS_SERVICE} --task-definition ${TASK_FAMILY}:${TASK_REVISION} --desired-count 1 --force-new-deployment
