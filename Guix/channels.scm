(cons*
  (channel
    (name 'nonguix)
    (url "https://gitlab.com/nonguix/nonguix")
    (introduction
      (make-channel-introduction
        "897c1a470da759236cc11798f4e0a5f7d4d59fbc"
        (openpgp-fingerprint
          "2A39 3FFF 68F4 EF7A 3D29 12AF 6F51 20A0 22FB B2D5"))))
  (channel
    (name 'gchannel)
    (url "https://github.com/GigiaJ/Guix-Personal-Packages.git")
    (branch "main"))
(channel
  (name 'efraim-dfsg)
  (url "https://git.sr.ht/~efraim/my-guix")
  (branch "master")
  (introduction
    (make-channel-introduction
      "61c9f87404fcb97e20477ec379b643099e45f1db"
      (openpgp-fingerprint
        "A28B F40C 3E55 1372 662D  14F7 41AA E7DC CA3D 8351"))))
        (channel
        (name 'small-guix)
        (url "https://codeberg.org/fishinthecalculator/small-guix.git")
        (branch "main")
        (introduction
         (make-channel-introduction
          "f260da13666cd41ae3202270784e61e062a3999c"
          (openpgp-fingerprint
           "8D10 60B9 6BB8 292E 829B  7249 AED4 1CC1 93B7 01E2"))))
    (channel
    (name 'saayix)
    (branch "main")
    (url "https://codeberg.org/look/saayix")
    (introduction
      (make-channel-introduction
        "12540f593092e9a177eb8a974a57bb4892327752"
        (openpgp-fingerprint
          "3FFA 7335 973E 0A49 47FC  0A8C 38D5 96BE 07D3 34AB"))))
  %default-channels)

