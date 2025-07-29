python /app/RFdiffusion/scripts/run_inference.py 'contigmap.contigs=[A33-267/0 80-80]'  'ppi.hotspot_res=[A223,A233,A241]' inference.input_pdb=/app/rfd_mpnn_af2_env/ebola_gp.pdb  inference.ckpt_override_path=/app/RFdiffusion/models/Complex_base_ckpt.pt
python /app/dl_binder_design/mpnn_fr/dl_interface_design.py -pdbdir /app/samples/
python /app/dl_binder_design/af2_initial_guess/predict.py -pdbdir /app/outputs/
