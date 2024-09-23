{{/*
Create a nodeAffinity definition
*/}}
{{- define "helpers.affinities.nodes" -}}
  {{- if eq .type "soft" }}
    {{- include "helpers.affinities.nodes.soft" . -}}
  {{- else if eq .type "hard" }}
    {{- include "helpers.affinities.nodes.hard" . -}}
  {{- end -}}
{{- end -}}

{{/*
Create a soft nodeAffinity definition
*/}}
{{- define "helpers.affinities.nodes.soft" -}}
preferredDuringSchedulingIgnoredDuringExecution:
  - preference:
      matchExpressions:
        - key: {{ .key }}
          operator: In
          values:
            {{- range .values }}
            - {{ . | quote }}
            {{- end }}
    weight: 1
{{- end -}}

{{/*
Create a hard nodeAffinity definition
*/}}
{{- define "helpers.affinities.nodes.hard" -}}
requiredDuringSchedulingIgnoredDuringExecution:
  nodeSelectorTerms:
    - matchExpressions:
        - key: {{ .key }}
          operator: In
          values:
            {{- range .values }}
            - {{ . | quote }}
            {{- end }}
{{- end -}}

{{/*
Create a podAffinity/podAntiAffinity definition
*/}}
{{- define "helpers.affinities.pods" -}}
  {{- if eq .type "soft" }}
    {{- include "helpers.affinities.pods.soft" . -}}
  {{- else if eq .type "hard" }}
    {{- include "helpers.affinities.pods.hard" . -}}
  {{- end -}}
{{- end -}}

{{/*
Create a topologyKey definition
*/}}
{{- define "helpers.affinities.topologyKey" -}}
{{ .topologyKey | default "kubernetes.io/hostname" -}}
{{- end -}}

{{/*
Create a soft podAffinity/podAntiAffinity definition
*/}}
{{- define "helpers.affinities.pods.soft" -}}
{{- $component := default "" .component -}}
{{- $customLabels := default (dict) .customLabels -}}
{{- $extraMatchLabels := default (dict) .extraMatchLabels -}}
{{- $extraPodAffinityTerms := default (list) .extraPodAffinityTerms -}}
preferredDuringSchedulingIgnoredDuringExecution:
  - podAffinityTerm:
      labelSelector:
        matchLabels: {{- (include "helpers.labels.matchLabels" ( dict "customLabels" $customLabels "context" .context )) | nindent 10 }}
          {{- if not (empty $component) }}
          {{ printf "app.kubernetes.io/component: %s" $component }}
          {{- end }}
          {{- range $key, $value := $extraMatchLabels }}
          {{ $key }}: {{ $value | quote }}
          {{- end }}
      topologyKey: {{ include "helpers.affinities.topologyKey" (dict "topologyKey" .topologyKey) }}
    weight: 1
  {{- range $extraPodAffinityTerms }}
  - podAffinityTerm:
      labelSelector:
        matchLabels: {{- (include "helpers.labels.matchLabels" ( dict "customLabels" $customLabels "context" $.context )) | nindent 10 }}
          {{- if not (empty $component) }}
          {{ printf "app.kubernetes.io/component: %s" $component }}
          {{- end }}
          {{- range $key, $value := .extraMatchLabels }}
          {{ $key }}: {{ $value | quote }}
          {{- end }}
      topologyKey: {{ include "helpers.affinities.topologyKey" (dict "topologyKey" .topologyKey) }}
    weight: {{ .weight | default 1 -}}
  {{- end -}}
{{- end -}}