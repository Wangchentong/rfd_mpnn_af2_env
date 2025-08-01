# 1.Scaffold generation option 1: RFdiffusion: motif scaffolding binder design with ACE2 motif
python /app/RFdiffusion/scripts/run_inference.py inference.input_pdb=/app/rfd_mpnn_af2_env/input/Spike_glycoprotein_complex.pdb 'contigmap.contigs=[B1-193/0 A19-42/60-60]' inference.ckpt_override_path=/app/RFdiffusion/models/Base_ckpt.pt denoiser.noise_scale_ca=0 denoiser.noise_scale_frame=0
# 1.Scaffold generation option 2: RFdiffusion: unconditional binder design
python /app/RFdiffusion/scripts/run_inference.py inference.input_pdb=/app/rfd_mpnn_af2_env/input/Spike_glycoprotein.pdb 'contigmap.contigs=[B1-193/0 90-90]' 'ppi.hotspot_res=[B120,B122,B123,B160,B172]' inference.ckpt_override_path=/app/RFdiffusion/models/Complex_base_ckpt.pt denoiser.noise_scale_ca=0 denoiser.noise_scale_frame=0
# 1.Scaffold generation option 3: RFdiffusion: topology guided binder design 
python /app/RFdiffusion/scripts/run_inference.py scaffoldguided.scaffoldguided=True scaffoldguided.scaffold_dir=/app/RFdiffusion/examples/ppi_scaffolds/ scaffoldguided.target_pdb=True scaffoldguided.target_path=/app/rfd_mpnn_af2_env/input/Spike_glycoprotein.pdb scaffoldguided.target_ss=/app/rfd_mpnn_af2_env/input/Spike_glycoprotein_ss.pt scaffoldguided.target_adj=/app/rfd_mpnn_af2_env/input/Spike_glycoprotein_adj.pt 'ppi.hotspot_res=[B120,B122,B123,B160,B172]' inference.ckpt_override_path=/app/RFdiffusion/models/Complex_Fold_base_ckpt.pt denoiser.noise_scale_ca=0 denoiser.noise_scale_frame=0
# 2. ProteinMPNN Sequence Design 
python /app/dl_binder_design/mpnn_fr/dl_interface_design.py -pdbdir ./samples/ -outpdbdir ./mpnn/ -relax_cycles 0 -seqs_per_struct 4
# 3. Alphafold2 complex structure prediction
python /app/dl_binder_design/af2_initial_guess/predict.py -pdbdir ./mpnn/ -outpdbdir ./predictions/ 
