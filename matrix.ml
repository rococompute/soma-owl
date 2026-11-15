(* The numerical work is Owl's. Only boundary conversions and reductions
   with a fixed axis live here; the network and its gradients are Soma. *)
module M = Owl.Dense.Matrix.D

type t = M.mat

let of_rows rows =
  match rows with
  | [] | [] :: _ -> invalid_arg "soma-owl: a matrix needs at least one row and column"
  | first :: _ ->
      let width = List.length first in
      if not (List.for_all (fun row -> List.length row = width) rows) then
        invalid_arg "soma-owl: matrix rows have different lengths";
      M.of_arrays (Array.of_list (List.map Array.of_list rows))

let to_rows x = Array.to_list (Array.map Array.to_list (M.to_arrays x))
let zeros rows cols = M.zeros rows cols
let seeded rows cols seed =
  let random = Random.State.make [|seed|] in
  let limit = sqrt (6. /. float_of_int (rows + cols)) in
  M.init_2d rows cols (fun _ _ -> (2. *. Random.State.float random 1. -. 1.) *. limit)
let rows x = M.row_num x
let cols x = M.col_num x
let add a b = M.add a b
let sub a b = M.sub a b
let mul a b = M.mul a b
let scale x scalar = M.mul_scalar x scalar
let dot a b = M.dot a b
let transpose x = M.transpose x
let mean_batch x = M.div_scalar x (float_of_int (M.row_num x))
let sum_rows x = M.sum_rows ~keep_dims:true x
let tanh x = M.tanh x
let tanh_gradient hidden = M.map (fun x -> 1. -. x *. x) hidden
let softmax x = M.softmax ~axis:1 x
let cross_entropy predicted expected =
  let safe = M.clip_by_value ~amin:1e-12 ~amax:1. predicted in
  -. M.sum' (M.mul expected (M.log safe)) /. float_of_int (M.row_num expected)
let format_float x = Printf.sprintf "%.6f" x
