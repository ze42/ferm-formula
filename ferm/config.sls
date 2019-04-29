{% set templates = {
   'ferm.conf': 'ferm.conf.jinja',
   'conf.d/10-policies.conf': 'policies.conf.jinja',
   'conf.d/20-conn-helpers.conf': 'conn-helpers.conf.jinja',
   'conf.d/49-nat.conf': 'nat.conf.jinja',
   'conf.d/50-rules.conf': 'rules.conf.jinja',
   'conf.d/51-forward.conf': 'forward.conf.jinja',
}
%}
{% set ferm_extra = salt['pillar.get']('ferm:extra') or {} %}

include:
  - .service

{% for filename, templatename in templates|dictsort %}
ferm_{{filename}}:
  file.managed:
    - name: /etc/ferm/{{ filename }}
    - source: salt://{{ slspath }}/templates/{{ templatename }}
    - template: jinja
    - makedirs: True
    - onchanges_in:
      - file: ferm_baseconfig
{% endfor %}

{% for basename, config in ferm_extra.items()|sort %}
ferm_extra_{{ basename }}:
  file.managed:
    - name: /etc/ferm/conf.d/{{ basename }}.conf
    - template: jinja
{% if 'contents' in config %}
    - contents: {{ config.contents|json }}
{% elif 'source' in config %}
{%   if '://' in config.source %}
    - source: {{ config.source }}
{%   elif config.source.startswith('/') %}
    - source: salt:/{{ config.source }}
{%   else %}
    - source: salt://{{ slspath }}/{{ config.source }}
{%   endif %}
{% else %}
    - contents: "# No source or contents found in pillar"
{% endif %}
    - makedirs: True
    - onchanges_in:
      - file: ferm_baseconfig
{% endfor %}


# Touch, so reload notice there has been changes...
# Debian init script uses cache, and only launch ferm to parse configuration if
# ferm.conf was changed since last generation.
ferm_baseconfig:
  file.touch:
    - name: /etc/ferm/ferm.conf
    - watch_in:
      - service: ferm_service
