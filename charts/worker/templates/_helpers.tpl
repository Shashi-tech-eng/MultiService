{{- define "worker.name" -}}
{{- .Release.Name }}-worker
{{- end }}

{{- define "worker.labels" -}}
app.kubernetes.io/name: worker
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
{{- end }}

{{- define "worker.selectorLabels" -}}
app.kubernetes.io/name: worker
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
