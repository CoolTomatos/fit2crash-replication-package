INPUT=inputs.csv
OLDIFS=$IFS
IFS=,
[ ! -f $INPUT ] && { echo "$INPUT file not found"; }
LIMIT=$1
job_list=()

counter=0
while read execution_idx application case version classpath package stacktrace_path fixed fixed_version buggy_frame p_functional_mocking functional_mocking_percent p_reflection_on_private reflection_start_percent search_budget population p_object_pool p_model_pool_target_init p_model_pool_non_target_init seed_clone seed_mutations test_dir
do
  if [[ "$counter" -eq "0" ]]; then
    counter=1
    continue
  fi

  valid_frames=$(python python/get_valid_frames.py $application $package $case)
  IFS='|' read -ra valid_frames_arr <<<"$valid_frames"

  for frame in "${!valid_frames_arr[@]}"; do
    task_json=$(python python/task_to_string.py $application $version $case ${valid_frames_arr[$frame]} $execution_idx $search_budget)
    job_list+=($task_json)
  done
done <$INPUT
echo "The number of tasks is "${#job_list[@]}""
counter=0
for t in ${job_list[@]}; do
  ((counter++))
  application=$(python python/get_from_json.py $t "application")
  version=$(python python/get_from_json.py $t "version")
  case=$(python python/get_from_json.py $t "case")
  frame=$(python python/get_from_json.py $t "frame")
  execution_idx=$(python python/get_from_json.py $t "execution_idx")
  search_budget=$(python python/get_from_json.py $t "search_budget")
  echo "Task#$counter is frame level $frame of issue $case. This crash happened in $application version $version. task configurations -> execution_idx: $execution_idx, search budget: $search_budget"

  ## Start the search process:
  java -d64 -Xmx4000m -jar ../lib/botsing-reproduction.jar -project_cp "../bins/$application/$version/bin/" -crash_log "../crashes/$application/$case/$case.log" -search_algorithm "Guided_MOSA" -fitness "IntegrationSingleObjective" -integration_testing -target_frame $frame -Dsearch_budget=$search_budget -Dstopping_condition=MAXFITNESSEVALUATIONS -Dreset_static_fields=FALSE -Dvirtual_fs=TRUE -Dmax_recursion=50 -Dvirtual_net=FALSE -Dreplace_calls=FALSE -Duse_separate_classloader=FALSE -Dtest_dir="results/$case-$frame-$execution_idx" >"logs/$case-$frame-$execution_idx-out.txt" 2>"logs/$case-$frame-$execution_idx-err.txt" &
  pid=$!
  echo $pid
  . parsing.sh $pid $execution_idx $application $case $version $frame $search_budget &
  . observer.sh $pid "$case-$frame-$execution_idx-out.txt" &

  while (($(pgrep -l java | wc -l) >= $LIMIT))
  do
    sleep 1
  done
done
