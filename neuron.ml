class neuron matrix character =
object (self)
  val mat : int array array = matrix
  val letter : char = character
  val size_x : int = Array.length matrix
  val size_y : int = Array.length matrix.(0)
  
  method get_letter = letter
  method compare matrix =
    let c = ref 0 in 
    for x = 0 to (size_x - 1) do
      for y = 0 to (size_y - 1) do
	begin
	if (matrix.(x).(y) = mat.(x).(y)) then
	  incr c;
	end
      done;
    done;
    !c

  method matching matrix =
    let c = self#compare matrix in
    let use = size_x * size_y / 2 in
    c >= use * 7 / 10    
end

let get_dims matrix = (Array.length matrix, Array.length matrix.(0))

let detect_top matrix = 
  let (x,y) = get_dims matrix
  and stop = ref false
  and i = ref 0 
  and j = ref 0 in
  while !i < x && not !stop do
    j := 0;
    while !j < y && not !stop do
      stop := (matrix.(!i).(!j) <> 0);
      j:= !j+1
    done;
    i := !i + 1
  done;
  (!i-1)

let detect_left matrix =
  let (x,y) = get_dims matrix in
  let i = ref 0 in
  let j = ref 0 in
  let stop = ref false in
  while !j < y && not !stop do
    i := 0;
    while !i < x && not !stop do
      stop := (matrix.(!i).(!j) <> 0);
      i := !i + 1;
    done;
    j := !j + 1
  done;
  !j - 1;;

let detect_down matrix =
  let (x,y) = get_dims matrix in
  let i = ref (x - 1) in
  let j = ref 0 in
  let stop = ref false in
  while !i >= 0 && not !stop do
    j := 0;
    while !j < y && not !stop do
      stop := (matrix.(!i).(!j) <> 0);
      j := !j + 1;
    done;
    i := !i - 1;
  done;
  !i + 1;;

let detect_right matrix =
  let (x,y) = get_dims matrix in
  let stop = ref false
  and i = ref 0
  and j = ref (y-1) in
  while !j > 0  && not !stop do
    i := 0;
    while !i < x && not !stop do
      stop := (matrix.(!i).(!j) <> 0);
      i := !i+1
    done;
    j := !j - 1;
  done;
  (!j + 1)

let float_to_int f =
  if (f -. float_of_int(int_of_float f) >= 0.5) then
    int_of_float f + 1
  else
    int_of_float f

let extend_mat_w matrix dest_y =
  let (x,y) = get_dims matrix in
  let dest_mat = Array.make_matrix x dest_y 0 in
  let mult_y = float_to_int((float dest_y) /. (float y)) in
  for i = 0 to x - 1 do
    for j = 0 to y - 1 do
      if (matrix.(i).(j) <> 0) then
	for m = 0 to mult_y - 1 do
	  let pos_y = mult_y * j + m in
	  if (pos_y < dest_y) then
	    dest_mat.(i).(pos_y) <- 1;
	done
    done
  done;
  dest_mat

let extend_mat_h matrix dest_x =
  let (x,y) = get_dims matrix in
  let dest_mat = Array.make_matrix dest_x y 0 in
  let mult_x = float_to_int((float dest_x) /. (float x)) in
  for i = 0 to x - 1 do
    for j = 0 to y - 1 do
      if (matrix.(i).(j) <> 0) then
	for n = 0 to mult_x - 1 do
	  let pos_x = mult_x * i + n in
	  if (pos_x < dest_x) then
	    dest_mat.(pos_x).(j) <- 1;
	done
    done
  done;
  dest_mat

let reduce_matrix_w matrix dest_y = 
  let (x,y) = get_dims matrix in
  let mult_y = float_to_int((float y) /. (float dest_y)) in
  let dest_mat = Array.make_matrix x dest_y 0
  and col = ref 0
  and max_col = ref 0
  and sum = ref 0 in
  for i = 0 to x - 1 do
    col := 0;
    max_col := 0;
    for j = 0 to dest_y - 1 do
      begin
	sum := 0;
	max_col := !max_col + mult_y; 
	while(!col < y && !col < !max_col) do
	  sum := !sum + matrix.(i).(!col);
	  col:= !col + 1
	done;
	if (float !sum) >= ((float mult_y) /. 2.) then
	  dest_mat.(i).(j) <- 1
      end
    done
  done;
  dest_mat

let reduce_matrix_h matrix dest_x =
  let (x,y) = get_dims matrix in
  let mult_x = float_to_int((float x) /. (float dest_x)) in
  let dest_mat = Array.make_matrix dest_x y 0
  and line = ref 0
  and max_line = ref 0
  and sum = ref 0 in
  for j = 0 to y - 1 do
    line := 0;
    max_line := 0;
    for i = 0 to dest_x - 1 do
      begin
	sum := 0;
	max_line := !max_line + mult_x; 
	while(!line < x && !line < !max_line) do
	    sum := !sum + matrix.(!line).(j);
	    line := !line + 1
	done;
	if (float !sum) >= ((float mult_x) /. 2.) then
	    dest_mat.(i).(j) <- 1
      end
    done
  done;
  dest_mat

let truncate matrix = 
  let border_top = detect_top matrix
  and border_right = detect_right matrix
  and border_down = detect_down matrix
  and border_left = detect_left matrix in
  let col = (border_right - border_left) + 1
  and lines = (border_down - border_top) + 1 in
  let trunc_mat = Array.make_matrix lines col 0
  and x = ref 0
  and y = ref 0 in
  for i = border_top to border_down do
    y := 0;
    for j = border_left to border_right do
      trunc_mat.(!x).(!y) <- matrix.(i).(j);
      y := !y + 1
    done;
    x := !x +1
  done;
  trunc_mat

let test =
  let mat = Array.make_matrix 12 13 0 in
  mat.(1).(2) <- 1;
  extend_matrix mat 3 4;;


let mmat =
  let mat = Array.make_matrix 4 4 0 in
  mat.(0).(0) <- 1;
  mat.(1).(1) <- 1;
  mat.(1).(2) <- 1;
  mat.(2).(1) <- 1;
  mat.(3).(2) <- 1;
  mat.(3).(3) <- 1;
  reduce_matrix_h mat 2;;
