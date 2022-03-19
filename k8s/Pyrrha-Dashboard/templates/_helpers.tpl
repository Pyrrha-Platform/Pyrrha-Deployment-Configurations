{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "mychart.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "apiauth.name" -}}
{{- default .Chart.Name .Values.auth.name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "apimain.name" -}}
{{- default .Chart.Name .Values.main.name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "dash.name" -}}
{{- default .Chart.Name .Values.dash.name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "mychart.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "mychart.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "apiauth.labels" -}}
app: {{ include "mychart.name" . }}-{{ .Values.auth.name }}
helm.sh/chart: {{ include "mychart.chart" . }}
{{ include "apiauth.selectorLabels" . }}
{{- if .Chart.AppVersion }}
version: {{ .Values.auth.image.tag | default .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}


{{- define "apimain.labels" -}}
app: {{ include "mychart.name" . }}-{{ .Values.main.name }}
helm.sh/chart: {{ include "mychart.chart" . }}
{{ include "apimain.selectorLabels" . }}
{{- if .Chart.AppVersion }}
version: {{ .Values.main.image.tag | default .Chart.AppVersion | quote }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}


{{- define "dash.labels" -}}
app: {{ include "mychart.name" . }}-{{ .Values.dash.name }}
helm.sh/chart: {{ include "mychart.chart" . }}
{{ include "dash.selectorLabels" . }}
{{- if .Chart.AppVersion }}
version: {{ .Values.dash.image.tag | default .Chart.AppVersion | quote }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
# {{- define "mychart.selectorLabels" -}}
# app.kubernetes.io/name: {{ include "mychart.name" . }}
# app.kubernetes.io/instance: {{ .Release.Name }}
# {{- end }}

{{- define "dash.selectorLabels" -}}
app.kubernetes.io/name:  {{ .Values.dash.name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "apimain.selectorLabels" -}}
app.kubernetes.io/name:  {{ .Values.main.name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "apiauth.selectorLabels" -}}
app.kubernetes.io/name:  {{ .Values.auth.name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}


