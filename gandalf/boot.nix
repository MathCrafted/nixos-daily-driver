{ config, pkgs, ... }:

{
  boot.loader.grub = {
    device = "nodev";
    useOSProber = false;
    extraEntries = ''
      #if [ "$grub_platform" = "efi" ]; then
      #menuentry 'Windows' --class windows --class os $menuentry_id_option 'osprober-efi-74C6-0CF3' {
      #	insmod part_gpt
      #	insmod fat
      #	search --no-floppy --fs-uuid --set=root 74C6-0CF3
      #	chainloader /EFI/Microsoft/Boot/bootmgfw.efi
      #}
      #fi
      
      menuentry 'Productivity Arch' --class arch --class gnu-linux --class gnu --class os $menuentry_id_option 'osprober-gnulinux-simple-cfe35870-bbf6-4c43-9128-e9403807d42d' {
      	insmod part_gpt
      	insmod fat
      	search --no-floppy --fs-uuid --set=root 74C6-0CF3
      
      	echo 'Loading Linux linux ...'
      	linux /vmlinuz-linux root=UUID=cfe35870-bbf6-4c43-9128-e9403807d42d rw loglevel=3 quiet
      	echo 'Loading initial ramdisk ...'
      	initrd /amd-ucode.img /initramfs-linux.img
      } 
    '';
  };
}
