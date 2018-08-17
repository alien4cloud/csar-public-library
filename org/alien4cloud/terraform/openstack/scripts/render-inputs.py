import argparse
import os

ENV_TF_PREFIX = "_TF_"
ENV_TFL_PREFIX = "_TFL_"
A4C_INSTANCE = "INSTANCE"
A4C_INSTANCES = "INSTANCES"

def get_a4c_current_instance_index():
  if A4C_INSTANCES not in os.environ:
    return 0
  else:
    env_instances = os.environ[A4C_INSTANCES]
    array = env_instances.split(",")
    array.sort()
    return array.index(os.environ[A4C_INSTANCE])

def extract_tfl_variables():
  tfl_variables = extract_variables(ENV_TFL_PREFIX)
  current_index = get_a4c_current_instance_index()
  extracted = {}
  for key, value in tfl_variables.iteritems():
    eval_value = eval(value)
    if eval_value:
      eval_value.sort()
      if current_index < len(eval_value):
        extracted[key] = '"{}"'.format(eval_value[current_index])
  return extracted

def extract_tf_variables():
  return extract_variables(ENV_TF_PREFIX)

def extract_variables(var_prefix):
  variables = {}
  for key, value in os.environ.iteritems():
    if key.startswith(var_prefix):
      rendered = render_env_value(value)
      variables[ key[len(var_prefix):len(key)] ] = rendered
  return variables


def render_env_value(value):
  rendered = ''
  if value.startswith('{'):
    evaluated = eval(value)
    rendered = '{\n'
    for key, value in evaluated.iteritems():
      rendered += '  {} = "{}"\n'.format(key, value)
    rendered += '}'
  elif value.startswith('['):
    evaluated = eval(value)
    rendered = '{}'.format(evaluated).replace("'",'"')
  else:
    rendered = '"' + value + '"'
  return rendered


def generate_tf_input(output_file):
  env_tf_variables   = extract_tf_variables()
  env_tfl_variables = extract_tfl_variables()

  with open(output_file, 'w') as f:
    for key, value in env_tf_variables.iteritems():
      f.write('{} = {}\n'.format(key, value))
    for key, value in env_tfl_variables.iteritems():
      f.write('{} = {}\n'.format(key, value))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('-o', '--output-file', type=str, required=False, default='output')
    kwargs = parser.parse_args()
    generate_tf_input(kwargs.output_file)


if __name__ == '__main__':
    main()
