# ECE 385 Final Project: fpga-galaga
fpga-galaga is a mock version of the classic arcade game Galaga. It is developed for the DE10-Lite MAX10 FPGA development board, with a custom arduino shield.

The project can be broken down into 13 submodules:
| Submodule                           | Description |
| :---------------------------------- | :---------- |
| Platform Designer SOC & ADC counter | Integrated multichannel ADC interface with shield joystick.                                              |
| 7 segment driver                    | Maps 4-bit binary literal to human readable hex data on 7 segment device.                                |
| Color mapper                        | Decide pixel color based on pixel position and which graphic element overlaps.                           |
| Player controlled ship              | Store ship position, update position given user input and bounds position.                               |
| Enemy & enemy FSM                   | Store enemy position, update position and sprite.                                                        |
| Bullet & bullet FSM                 | Store bullet position, update position given user input and hit detection.                               |
| Hit detection                       | Detect bullet sprite intersection with specific enemy sprite/top of screen, track which enemies are hit. |
| VGA controller                      | Provide proper clock timings and sync pulses to VGA device.                                              |
| Sprite & font ROM                   | Bitmaps of used ASCII characters and game sprites, with encoded color values via LUT.                    |

## Building
fpga-galaga can be compiled with the provided ```Makefile```. Building was tested using Quartus Lite 18.1. A simple help prompt can be found via ```make help```.
