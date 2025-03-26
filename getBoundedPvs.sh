#!/bin/bash
#Author: Renan Cirello
#E-mail: rcirello@gmail.com / rcirello@redhat.com
#Objective: Get All bounded PVs across an OpenShift Cluster

boundedPVS=$(oc get pv -A -o yaml | yq '.[].[] | select(.status.phase == "Bound").metadata.name')

test "${1}" == "CSV" && echo "PV,Namespace,PVC,Deployment,Pod"

for pv in ${boundedPVS}
do
  pvStorageClass="$(oc get pv -A ${pv} -o yaml | yq '.spec.storageClassName')"
  pvcName="$(oc get pv -A ${pv} -o yaml | yq '.spec.claimRef.name')"
  pvcNamespace="$(oc get pv -A ${pv} -o yaml | yq '.spec.claimRef.namespace')"
  deploymentName="$(oc get deployment -n ${pvcNamespace} -o yaml | yq ".[].[] | select(.spec.template.spec.volumes.[].persistentVolumeClaim.claimName == \"${pvcName}\") | .metadata.name")"
  podName="$(oc get pod -n ${pvcNamespace} -o yaml | yq ".[].[] | select(.spec.volumes.[].persistentVolumeClaim.claimName == \"${pvcName}\") | .metadata.name")"

  if [ "${1}" == "CSV" ]; then
    echo "${pv},${pvStorageClass},${pvcNamespace},${pvcName},${deploymentName},${podName}"
  else
    echo "############# PV ${pv}"
    echo "StorageClass -> ${pvStorageClass}"
    echo "Namespace    -> ${pvcNamespace}"
    echo "PVC          -> ${pvcName}" 
    echo "Deployment   -> ${deploymentName}"
    echo "Pod          -> ${podName}"
    echo 
  fi
done
