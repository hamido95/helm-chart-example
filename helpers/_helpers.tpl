{{/*
define the kubernetes version 
*/}}
{{- define "helpers.helpers.kubeVersion" -}}
{{- default (default .Capabilities.kubeVersion.Version .Values.kubeVersion) ((.Values.Global).kubeVersion) -}}
{{- end -}}

{{/*
Create target apiVersion for deployment.
*/}}
{{- define "helpers.helpers.deployment.apiVersion" -}}
{{- print "apps/v1" -}}
{{- end -}}

{{/*
Create target apiVersion for service.
*/}}
{{- define "helpers.helpers.service.apiVersion" -}}
{{- print "v1" -}}
{{- end -}}

{{/*
Create target apiVersion for poddisruptionbudget.
*/}}
{{- define "helpers.helpers.pdb.apiVersion" -}}
{{- $kubeVersion := include "helpers.helpers.kubeVersion" . -}}
{{- if and (not (empty $kubeVersion)) (semverCompare "<1.21-0" $kubeVersion) -}}
{{- print "policy/v1beta1" -}}
{{- else -}}
{{- print "policy/v1" -}}
{{- end -}}
{{- end -}}

{{/*
Create target apiVersion for networkpolicy.
*/}}
{{- define "helpers.helpers.networkPolicy.apiVersion" -}}
{{- print "networking.k8s.io/v1" -}}
{{- end -}}

{{/*
Create target apiVersion for cronjob.
*/}}
{{- define "helpers.helpers.cronjob.apiVersion" -}}
{{- $kubeVersion := include "helpers.helpers.kubeVersion" . -}}
{{- if and (not (empty $kubeVersion)) (semverCompare "<1.21-0" $kubeVersion) -}}
{{- print "batch/v1beta1" -}}
{{- else -}}
{{- print "batch/v1" -}}
{{- end -}}
{{- end -}}

{{/*
Create target apiVersion for daemonset.
*/}}
{{- define "helpers.helpers.daemonset.apiVersion" -}}
{{- print "apps/v1" -}}
{{- end -}}

{{/*
Create target apiVersion for statefulset.
*/}}
{{- define "helpers.helpers.statefulset.apiVersion" -}}
{{- print "apps/v1" -}}
{{- end -}}

{{/*
Create target apiVersion for ingress.
*/}}
{{- define "helpers.helpers.ingress.apiVersion" -}}
{{- $kubeVersion := include "helpers.helpers.kubeVersion" . -}}
{{- if and (not (empty $kubeVersion)) (semverCompare "<1.19-0" $kubeVersion) -}}
{{- print "networking.k8s.io/v1beta1" -}}
{{- else -}}
{{- print "networking.k8s.io/v1" -}}
{{- end -}}
{{- end -}}

{{/*
Create target apiVersion for RBAC resources.
*/}}
{{- define "helpers.helpers.rbac.apiVersion" -}}
{{- print "rbac.authorization.k8s.io/v1" -}}
{{- end -}}

{{/*
Create target apiVersion for HPA.
*/}}
{{- define "helpers.helpers.hpa.apiVersion" -}}
{{- $kubeVersion := include "helpers.helpers.kubeVersion" .context -}}
{{- if and (not (empty $kubeVersion)) (semverCompare "<1.23-0" $kubeVersion) -}}
{{- if .beta2 -}}
{{- print "autoscaling/v2beta2" -}}
{{- else -}}
{{- print "autoscaling/v2beta1" -}}
{{- end -}}
{{- else -}}
{{- print "autoscaling/v2" -}}
{{- end -}}
{{- end -}}

{{/*
Create target apiVersion for persistent volumes claims.
*/}}
{{- define "helpers.helpers.pvc.apiVersion" -}}
{{- print "v1" -}}
{{- end -}}

{{/*
check if PodSecurityPolicy is supported.
*/}}
{{- define "helpers.helpers.psp.supported" -}}
{{- $kubeVersion := include "helpers.helpers.kubeVersion" . -}}
{{- if or (empty $kubeVersion) (semverCompare "<1.25-0" $kubeVersion) -}}
  {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Expand the name of the chart.
*/}}
{{- define "helpers.helpers.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "helpers.helpers.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "helpers.helpers.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified dependency name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
Usage:
{{ include "helpers.helpers.dependency.fullname" (dict "chartName" "dependency-chart-name" "chartValues" .Values.dependency-chart "context" $) }}
*/}}
{{- define "helpers.helpers.dependency.fullname" -}}
{{- if .chartValues.fullnameOverride -}}
{{- .chartValues.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .chartName .chartValues.nameOverride -}}
{{- if contains $name .context.Release.Name -}}
{{- .context.Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .context.Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Allow the release namespace to be overridden for multi-namespace deployments in combined charts.
*/}}
{{- define "helpers.helpers.namespace" -}}
{{- default .Release.Namespace .Values.namespaceOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a fully qualified app name adding the installation's namespace.
*/}}
{{- define "helpers.helpers.fullname.namespace" -}}
{{- printf "%s-%s" (include "helpers.helpers.fullname" .) (include "helpers.helpers.namespace" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "helpers.helpers.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "helpers.helpers.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
check if the Helm version is 3.3+.
*/}}
{{- define "helpers.helpers.supportsHelmVersion" -}}
{{- if regexMatch "{(v[0-9])*[^}]*}}$" (.Capabilities | toString ) }}
  {{- true -}}
{{- end -}}
{{- end -}}