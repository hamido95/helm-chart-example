{{/*
Create kubernetes standard labels
*/}}
{{- define "helpers.labels.standard" -}}
{{- if and (hasKey . "customLabels") (hasKey . "context") -}}
{{- $default := dict "app.kubernetes.io/name" (include "helpers.helpers.name" .context) "helm.sh/chart" (include "helpers.helpers.chart" .context) "app.kubernetes.io/instance" .context.Release.Name "app.kubernetes.io/managed-by" .context.Release.Service -}}
{{- with .context.Chart.AppVersion -}}
{{- $_ := set $default "app.kubernetes.io/version" . -}}
{{- end -}}
{{ merge .customLabels $default | toYaml | nindent 2 }}
{{- else -}}
app.kubernetes.io/name: {{ include "helpers.helpers.name" . }}
helm.sh/chart: {{ include "helpers.helpers.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Chart.AppVersion }}
app.kubernetes.io/version: {{ . | quote }}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Labels for fields such as deploy.spec.selector.matchLabels or svc.spec.selector
*/}}
{{- define "helpers.labels.matchLabels" -}}
{{- if and (hasKey . "customLabels") (hasKey . "context") -}}
  {{- $default := dict "app.kubernetes.io/name" (include "helpers.helpers.name" .context) "app.kubernetes.io/instance" .context.Release.Name -}}
{{- else -}}
app.kubernetes.io/name: {{ include "helpers.helpers.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "helpers.helpers.labels" -}}
helm.sh/chart: {{ include "helpers.helpers.chart" . }}
{{ include "helpers.helpers.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "helpers.helpers.selectorLabels" -}}
app.kubernetes.io/name: {{ include "helpers.helpers.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
