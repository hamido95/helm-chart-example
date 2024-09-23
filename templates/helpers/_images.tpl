{{/*
Create image name.
*/}}
{{- define "helpers.images.image" -}}
{{- $registryName := default .imageRoot.registry ((.global).imageRegistry) -}}
{{- $repositoryName := .imageRoot.repository -}}
{{- $separator := ":" -}}
{{- $termination := .imageRoot.tag | toString -}}

{{- if not .imageRoot.tag }}
  {{- if .chart }}
    {{- $termination = .chart.AppVersion | toString -}}
  {{- end -}}
{{- end -}}
{{- if $registryName }}
    {{- printf "%s/%s%s%s" $registryName $repositoryName $separator $termination -}}
{{- else -}}
    {{- printf "%s%s%s"  $repositoryName $separator $termination -}}
{{- end -}}
{{- end -}}

{{/*
Create imagePullSecrets for a single or multiple image registries.
*/}}
{{- define "helpers.images.renderPullSecrets" -}}

  {{- $pullSecrets := list }}
  
  {{- if .Values.global.imagePullSecrets -}}
    {{- range .Values.global.imagePullSecrets -}}
      {{- $pullSecrets = append $pullSecrets . -}}
    {{- end -}}
  {{- end -}}

  {{- range .images -}}
    {{- if .pullSecrets -}}
      {{- range .pullSecrets -}}
        {{- $pullSecrets = append $pullSecrets . -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}

  {{- if (not (empty $pullSecrets)) -}}
imagePullSecrets:
  {{- range $pullSecrets | uniq }}
  - name: {{ . }}
  {{- end }}
  {{- end -}}
{{- end -}}
{{/*
Create image version. if not set fallbacks to chart appVersion.
*/}}
{{- define "helpers.images.version" -}}
{{- $imageTag := .imageRoot.tag | toString -}}
{{- if regexMatch `^([0-9]+)(\.[0-9]+)?(\.[0-9]+)?(-([0-9A-Za-z\-]+(\.[0-9A-Za-z\-]+)*))?(\+([0-9A-Za-z\-]+(\.[0-9A-Za-z\-]+)*))?$` $imageTag -}}
    {{- $version := semver $imageTag -}}
    {{- printf "%d.%d.%d" $version.Major $version.Minor $version.Patch -}}

{{- else if regexMatch `^[0-9]+-[0-9]+$` $imageTag -}}
    {{- $buildID := regexFind `^[0-9]+` $imageTag -}}
    {{- $pipelineID := regexFind `[0-9]+$` $imageTag -}}
    {{- printf "%s-%s" $buildID $pipelineID -}}
{{- else -}}
    {{- print .chart.AppVersion -}}
{{- end -}}
{{- end -}}