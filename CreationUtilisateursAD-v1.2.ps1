#---------------------------------------------------------------------------------------------------------------------------
# Auteur :        Stella Alexis
# Date:           26.09.2019
# Version :       1.2
# Modifié :       GRE 11.10.2019 (esthétique et valeurs par défaut)
#                 GRE 16.10.2019 (suppression des accents)
#
# Description :   Ce script va permettre de créer des utilisateurs AD et les ajouter à des groupes grâce à un fichier CSV fournit par l'utilisateur qui lance ce script
#
# Exemple de fichier CSV (deux premières lignes) : 
#
#   "firstName";"lastName";"username";"password"
#   "Mary";"Baker";"mbaker";"Emf12345"
#---------------------------------------------------------------------------------------------------------------------------

#################################################################################################################
#  Importation du module Active Directory
#################################################################################################################

#Test si le script arrive à importer le module ActiveDirectory
Try {
    Import-Module ActiveDirectory -ErrorAction Stop
}
Catch {
    Write-Host "[ERREUR]`t Le module ActiveDirectory n'a pas été chargé. Script stoppé!"
    Write-Host "`t `t Appuyer sur une touche pour fermer la fenêtre"
    [void][System.Console]::ReadKey($true)
    Exit 1
}

#################################################################################################################
#  function Hide-Powershell() will hide the console
#################################################################################################################

$Script:showWindowAsync = Add-Type -MemberDefinition @"
[DllImport("user32.dll")]
public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
"@ -Name "Win32ShowWindowAsync" -Namespace Win32Functions -PassThru
Function Show-Powershell()
{
    $null = $showWindowAsync::ShowWindowAsync((Get-Process -Id $pid).MainWindowHandle, 10)
}
Function Hide-Powershell()
{
    $null = $showWindowAsync::ShowWindowAsync((Get-Process -Id $pid).MainWindowHandle, 2)
}

#################################################################################################################
#  function showUsers
#################################################################################################################

#Cette fonction ajoute les utilisateurs du fichier csv dans la checkedListeBox1
function showUsers($csvUsers) {
    foreach ($User in $csvUsers) {
        $Username =  $User.username
        $Password = $User.password
        $Firstname =  $User.firstname
        $Lastname =   $User.lastname
        $checkedListBoxCSVUsers.Items.Add($Firstname + " " + $Lastname + " " + $Username + " " + $Password) | Out-Null
    }
}

#################################################################################################################
#  function showGroups
#################################################################################################################

#Cette fonction ajoute les groupes de l'ActiveDirectory dans la checkedListeBox2
function showGroups($selectedOU) {
    $lgroup = Get-ADGroup -filter { GroupCategory -eq "Security" -and GroupScope -eq "Global" } -SearchBase $selectedOU
    foreach ($lg in $lgroup) {
        $checkedListBoxGroups.Items.Add($lg.name) | Out-Null
    }   
}

#################################################################################################################
#  function createDefaultCSVFile
#################################################################################################################

#Cette fonction créé un fichier CSV avec des valeurs fixes 
function createDefaultCSVFile($path) {
    [pscustomobject]@{ firstName =  'Walter'; lastName = 'White'; username = 'wwhite'; password = 'Emf12345' } | Export-Csv -Path $csvFilePath -Delimiter ';' -NoTypeInformation
    [pscustomobject]@{ firstName =  'Jessie'; lastName = 'Pinkman'; username = 'jpinkman'; password = 'Emf12345' } | Export-Csv -Path  $csvFilePath -Append -Delimiter ';' -NoTypeInformation
    [pscustomobject]@{ firstName =  'Saul'; lastName = 'Goodman'; username = 'sgoodman'; password = 'Emf12345' } | Export-Csv -Path  $csvFilePath -Append -Delimiter ';' -NoTypeInformation
    [pscustomobject]@{ firstName =  'Gustavo'; lastName = 'Fringe'; username = 'gfringe'; password = 'Emf12345' } | Export-Csv -Path  $csvFilePath -Append -Delimiter ';' -NoTypeInformation 
}

#################################################################################################################
#  function importCSVFile ($path)
#################################################################################################################

function importCSVFile($path) {

    #Importation du fichier csv en enlevant les accents
    $Content = Get-Content -Path $path
    $replaceTable = @{"ß"="ss";"à"="a";"á"="a";"â"="a";"ã"="a";"ä"="a";"å"="a";"æ"="ae";"ç"="c";"è"="e";"é"="e";"ê"="e";"ë"="e";"ì"="i";"í"="i";"î"="i";"ï"="i";"ð"="d";"ñ"="n";"ò"="o";"ó"="o";"ô"="o";"õ"="o";"ö"="o";"ø"="o";"ù"="u";"ú"="u";"û"="u";"ü"="u";"ý"="y";"þ"="p";"ÿ"="y"}

    foreach($key in $replaceTable.Keys){
        $Content = $Content.Replace($key,$replaceTable.$key)
    }

    return $users = ConvertFrom-Csv -InputObject $Content -Delimiter ";"
}

#################################################################################################################
#  function GenerateForm (exécutée au lancement  du programme)
#################################################################################################################

#Generated Form Function
function GenerateForm {
    ########################################################################
    # Code Generated By: SAPIEN Technologies PrimalForms (Community Edition) v1.0.10.0
    # Generated On: 12.09.2019 11:04
    # Generated By: StellaA
    ########################################################################
    
    #region Import the Assemblies
    [reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null
    [reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null
    #endregion

    #Hides the console
    Hide-Powershell

    #region Generated Form Objects
    $form1 = New-Object System.Windows.Forms.Form
    $checkBox1 = New-Object System.Windows.Forms.CheckBox
    $button4 = New-Object System.Windows.Forms.Button
    $richTextBox1 = New-Object System.Windows.Forms.RichTextBox
    $button3 = New-Object System.Windows.Forms.Button
    $button2 = New-Object System.Windows.Forms.Button
    $label3 = New-Object System.Windows.Forms.Label
    $comboOUUsers = New-Object System.Windows.Forms.ComboBox
    $checkedListBoxGroups = New-Object System.Windows.Forms.CheckedListBox
    $checkedListBoxCSVUsers = New-Object System.Windows.Forms.CheckedListBox
    $label5 = New-Object System.Windows.Forms.Label
    $comboOUGroups = New-Object System.Windows.Forms.ComboBox
    $button1 = New-Object System.Windows.Forms.Button
    $textBoxCSVFile = New-Object System.Windows.Forms.TextBox
    $label2 = New-Object System.Windows.Forms.Label
    $label1 = New-Object System.Windows.Forms.Label
    $InitialFormWindowState = New-Object System.Windows.Forms.FormWindowState
    #endregion Generated Form Objects

    #----------------------------------------------
    #Generated Event Script Blocks
    #----------------------------------------------  

    #Nous mettons un chemin par defaut au lancement et nous importons le fichier "csv" par rapport au chemin par defaut
    #Test si l'emplacement du fichier est bon, sinon il créer un fichier sur le bureau avec des valeurs par défaut dedans
    $csvFilePath = "$env:USERPROFILE\Desktop\newusers.csv"
    if (-not(Test-Path -Path $csvFilePath)) {createDefaultCSVFile($csvFilePath)}
    $Content = Get-Content -Path $csvFilePath
    $Content = $Content.Replace('é','e')
    $csvUsers = ConvertFrom-Csv -InputObject $Content -Delimiter ";"
    $textBoxCSVFile.Text = $csvFilePath

    #Permet de lancer la fonction showUsers pour afficher les utilisateurs du fichier "csv"
    showUsers($csvUsers)

    #Mettre toutes les unités d'organisation du serveur dans la liste déroulante $comboOUGroups (liste des groupes)
    $OUs = Get-ADOrganizationalUnit -Filter "*"
    foreach ($OU in $OUs) {
        $comboOUGroups.Items.Add($OU) | Out-Null
    }

    #Choisir une OU par défaut dans laquelle il y a au moins un groupe global
    $index = 0
    $selectedIndex= 0
    #Répéter pour chaque OU de la combobox
    foreach ($OU in $comboOUGroups.Items) {
        #Trouver les groupes globaux contenus dan l'OU
        $globalGroups = Get-ADGroup -filter { GroupCategory -eq "Security" -and GroupScope -eq "Global" } -SearchBase $OU.DistinguishedName -SearchScope OneLevel
        #Si l'OU contient au moins un groupe global
        if ($globalGroups.count -gt 0) {
            #alors $selectedIndex prend la valeur actuelle de l'index
            $selectedIndex = $index
        }
        $index++    
    }
    $comboOUGroups.SelectedIndex = $selectedIndex

    #Permet de lancer la fonction pour ajouter les groupes dans la checkedListBox correspondante
    showGroups($comboOUGroups.SelectedItem)

    #Mettre toutes les unités d'organisation du serveur dans la liste déroulante comboUsers (destination des users)
    foreach ($OU in $OUs) {
        $comboOUUsers.Items.Add($OU) | Out-Null
    }

    #Choisir une OU par défaut dans laquelle il y a au moins un user
    $index = 0
    $selectedIndex= 0
    #Répéter pour chaque OU de la combobox
    foreach ($OU in $comboOUUsers.Items) {
        #Trouver les users contenus dans l'OU
        $users = Get-ADUser -Filter * -SearchBase $OU -SearchScope OneLevel
        #Si l'OU contient au moins un user
        if ($users.count -gt 0) {
            #alors $selectedIndex prend la valeur actuelle de l'index
            $selectedIndex = $index
        }
        $index++    
    }
    $comboOUUsers.SelectedIndex = $selectedIndex

    #################################################################################################################
    #  handler_button1_Click
    #################################################################################################################

    #Fonction exécutée quand on clique sur le bouton browse
    $handler_button1_Click = {

        # Browse for folders and populate the textbox1  
        Add-Type -AssemblyName System.Windows.Forms

        $FolderBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{
            Multiselect = $false
            Filter      = 'Fichier (*.csv, *.txt)|*.csv;*.txt' # Specified file types
            Title       = 'Choisir un fichier csv'
        }

        [void]$FolderBrowser.ShowDialog()
        
        $selectedCSVFile = $FolderBrowser.FileName

        #Test si le path est null, si oui, on met un chemin par défaut
        if ($selectedCSVFile -eq "") {
            $selectedCSVFile = $csvFilePath 
        }
        $textBoxCSVFile.Text = $selectedCSVFile

        #Importation du fichier csv en enlevant les accents
        $csvUsers = importCSVFile -path $selectedCSVFile

        $checkedListBoxCSVUsers.Items.Clear()
        showUsers($csvUsers)

        #Vidange de l'affichage
        $richTextBox1.Clear()

        #Affichage des groupes
        $checkedListBoxGroups.Items.Clear()
        showGroups($comboOUGroups.SelectedItem)
    }

    #################################################################################################################
    #  comboGroupsOU_SelectedIndexChanged
    #################################################################################################################

    #Fonction exécutée quand on change l'OU sélectionnée dans la comboGroupsOU
    $comboOUGroups_SelectedIndexChanged =
    {
        $checkedListBoxGroups.Items.Clear()

        $globalGroups = Get-ADGroup -filter { GroupCategory -eq "Security" -and GroupScope -eq "Global" } -SearchBase $comboOUGroups.SelectedItem
        foreach ($globalGroup in $globalGroups) {
            $checkedListBoxGroups.Items.Add($globalGroup.name)
        }
    }

    #################################################################################################################
    #  $button3_OnClick
    #################################################################################################################

    #Fonction exécutée quand on clique sur le bouton select all groups
    $button3_OnClick = 
    {
        #Vérifie s'il y a un utilisateur non checké, si c'est le cas, sélectionne tous les
        #utilisateur, sinon, déselectionne tous les utilisateurs
        $checkToutSelect = $false
        for ($i = 0; $i -lt $checkedListBoxGroups.Items.count; $i++) {
            if ($checkedListBoxGroups.GetItemChecked($i) -eq $false) {
                $checkToutSelect = $true
                break
            }    
        }
        if ($checkToutSelect) {
            for ($i = 0; $i -lt $checkedListBoxGroups.Items.count; $i++) {
                $checkedListBoxGroups.SetItemChecked($i, $true)
            }
        }
        else {
            for ($i = 0; $i -lt $checkedListBoxGroups.Items.count; $i++) {
                $checkedListBoxGroups.SetItemChecked($i, $false)
            } 
        }
    }

    #################################################################################################################
    #  $button2_OnClick
    #################################################################################################################

    #Fonction exécutée quand on clique sur le bouton select all users
    
    $button2_OnClick = 
    {
        #Vérifie s'il y a un utilisateur non checké, si c'est le cas, sélectionne tous les
        #utilisateur, sinon, déselectionne tous les utilisateurs
        $checkToutSelect = $false
        for ($i = 0; $i -lt $checkedListBoxCSVUsers.Items.count; $i++) {
            if ($checkedListBoxCSVUsers.GetItemChecked($i) -eq $false) {
                $checkToutSelect = $true
                break
            }    
        }
        if ($checkToutSelect) {
            for ($i = 0; $i -lt $checkedListBoxCSVUsers.Items.count; $i++) {
                $checkedListBoxCSVUsers.SetItemChecked($i, $true)
            }
        }
        else {
            for ($i = 0; $i -lt $checkedListBoxCSVUsers.Items.count; $i++) {
                $checkedListBoxCSVUsers.SetItemChecked($i, $false)
            } 
        }
    }

    #################################################################################################################
    #  $button4_OnClick
    #################################################################################################################

    #Fonction exécutée quand on clique sur le bouton execute
    
    $button4_OnClick = 
    {


        #Importation du fichier csv en enlevant les accents
        $csvUsers = importCSVFile -path $textBoxCSVFile.Text

        foreach ($itm in $checkedListBoxCSVUsers.CheckedIndices) {
            $compt = 0
            $var = $itm
            foreach ($User in $csvUsers) {
                #Test si la case est coché, si oui, il créer l'utilisateur
                if ($var -eq $compt) {
                    $Username =  $User.username
                    $Password = $User.password
                    $Firstname =  $User.firstname
                    $Lastname =  $User.lastname
                    $OU = $comboOUUsers.SelectedItem
                    if ($checkBox1.Checked) {
                        $passLogon = $true                        
                    }
                    else {
                        $passLogon = $false 
                    }

                    #Regarde si l'utisateur existe déjà dans AD
                    if (Get-ADUser  -F { SamAccountName -eq $Username }) {
                        #Si oui, il met un message : "ATTENTION"
                        $richTextBox1.AppendText("ATTENTION: L'utilisateur $Username existe déjà dans l'Active Directory. `n" )
                        $richTextBox1.AppendText("----------------------------------------------------------------------" + "`n")
                    }
                    else {
                        # Si l'utilisateur n'existe pas. il le crée

                        #On trouve le nom du domaine (exemple : lan.local)
                        $UPN = (Get-adforest).Name
    
                        #On créé l'utilisateur
                        New-ADUser `
                            -SamAccountName $Username `
                            -UserPrincipalName "$Username@$UPN" `
                            -Name "$Firstname $Lastname" `
                            -GivenName $Lastname `
                            -Surname $Firstname `
                            -Enabled $true `
                            -ChangePasswordAtLogon $passLogon `
                            -DisplayName "$Lastname, $Firstname" `
                            -Path $OU `
                            -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -Force)
                        $gp = ""
                        foreach ($groupes in $checkedListBoxGroups.CheckedIndices) {
                            $gp += $checkedListBoxGroups.Items[$groupes] + " | "
                            Add-ADGroupMember -identity  $checkedListBoxGroups.Items[$groupes] -Members $Username -EA 0  
                        }       
                        $richTextBox1.AppendText("l'utilisateur $Username à été créé correctement et ajouté au(x) groupe(s) : " + $gp + "`n")
                        $richTextBox1.AppendText("----------------------------------------------------------------------" + "`n")
                    }  
                }
                $compt += 1
            }
        }    
    }    

    #################################################################################################################
    #  $OnLoadForm_StateCorrection
    #################################################################################################################

    $OnLoadForm_StateCorrection =
    { #Correct the initial state of the form to prevent the .Net maximized form issue
        $form1.WindowState = $InitialFormWindowState
    }
    
    #----------------------------------------------
    #region Generated Form Code
    $form1.BackgroundImageLayout = 2
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 581
    $System_Drawing_Size.Width = 764
    $form1.ClientSize = $System_Drawing_Size
    $form1.DataBindings.DefaultDataSourceUpdateMode = 0
    $form1.Name = "form1"
    $form1.Text = "Création d'utilisateurs AD"

    $checkBox1.DataBindings.DefaultDataSourceUpdateMode = 0
    $checkBox1.Font = New-Object System.Drawing.Font("Microsoft Sans Serif", 11.25, 0, 3, 0)

    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 42
    $System_Drawing_Point.Y = 401
    $checkBox1.Location = $System_Drawing_Point
    $checkBox1.Name = "checkBox1"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 24
    $System_Drawing_Size.Width = 540
    $checkBox1.Size = $System_Drawing_Size
    $checkBox1.TabIndex = 22
    $checkBox1.Text = "Demander à l'utilisateur créé de changer le mdp à la première connexion"
    $checkBox1.UseVisualStyleBackColor = $True
    $checkBox1.add_CheckedChanged($handler_checkBox1_CheckedChanged)

    $form1.Controls.Add($checkBox1)
    
    
    $button4.DataBindings.DefaultDataSourceUpdateMode = 0
    $button4.Font = New-Object System.Drawing.Font("Microsoft Sans Serif", 9.75, 0, 3, 0)
    
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 615
    $System_Drawing_Point.Y = 374
    $button4.Location = $System_Drawing_Point
    $button4.Name = "button4"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 37
    $System_Drawing_Size.Width = 110
    $button4.Size = $System_Drawing_Size
    $button4.TabIndex = 21
    $button4.Text = "Lancer"
    $button4.UseVisualStyleBackColor = $True
    $button4.add_Click($button4_OnClick)
    
    $form1.Controls.Add($button4)
    
    $richTextBox1.DataBindings.DefaultDataSourceUpdateMode = 0
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 42
    $System_Drawing_Point.Y = 431
    $richTextBox1.Location = $System_Drawing_Point
    $richTextBox1.Name = "richTextBox1"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 133
    $System_Drawing_Size.Width = 683
    $richTextBox1.Size = $System_Drawing_Size
    $richTextBox1.TabIndex = 20
    $richTextBox1.Text = ""
    $richTextBox1.Readonly = $True
    
    $form1.Controls.Add($richTextBox1)
    
    
    $button3.DataBindings.DefaultDataSourceUpdateMode = 0
    $button3.Font = New-Object System.Drawing.Font("Microsoft Sans Serif", 9.75, 0, 3, 0)
    
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 415
    $System_Drawing_Point.Y = 151
    $button3.Location = $System_Drawing_Point
    $button3.Name = "button3"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 25
    $System_Drawing_Size.Width = 133
    $button3.Size = $System_Drawing_Size
    $button3.TabIndex = 19
    $button3.Text = "Tout selectionner"
    $button3.UseVisualStyleBackColor = $True
    $button3.add_Click($button3_OnClick)
    
    $form1.Controls.Add($button3)
    
    
    $button2.DataBindings.DefaultDataSourceUpdateMode = 0
    $button2.Font = New-Object System.Drawing.Font("Microsoft Sans Serif", 9.75, 0, 3, 0)
    
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 42
    $System_Drawing_Point.Y = 151
    $button2.Location = $System_Drawing_Point
    $button2.Name = "button2"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 26
    $System_Drawing_Size.Width = 133
    $button2.Size = $System_Drawing_Size
    $button2.TabIndex = 18
    $button2.Text = "Tout selectionner"
    $button2.UseVisualStyleBackColor = $True
    $button2.add_Click($button2_OnClick)
    
    $form1.Controls.Add($button2)
    
    $label3.DataBindings.DefaultDataSourceUpdateMode = 0
    $label3.Font = New-Object System.Drawing.Font("Microsoft Sans Serif", 11.25, 0, 3, 0)
    
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 41
    $System_Drawing_Point.Y = 343
    $label3.Location = $System_Drawing_Point
    $label3.Name = "label3"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 19
    $System_Drawing_Size.Width = 455
    $label3.Size = $System_Drawing_Size
    $label3.TabIndex = 17
    $label3.Text = "Choisir l'endroit où vont être stockés les utilisateurs (OU) :"
    
    $form1.Controls.Add($label3)
    
    $comboOUUsers.DataBindings.DefaultDataSourceUpdateMode = 0
    $comboOUUsers.FormattingEnabled = $True
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 42
    $System_Drawing_Point.Y = 374
    $comboOUUsers.Location = $System_Drawing_Point
    $comboOUUsers.Name = "comboBox1"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 21
    $System_Drawing_Size.Width = 300
    $comboOUUsers.Size = $System_Drawing_Size
    $comboOUUsers.TabIndex = 16
    
    $form1.Controls.Add($comboOUUsers)
    
    $checkedListBoxGroups.DataBindings.DefaultDataSourceUpdateMode = 0
    $checkedListBoxGroups.FormattingEnabled = $True
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 415
    $System_Drawing_Point.Y = 186
    $checkedListBoxGroups.Location = $System_Drawing_Point
    $checkedListBoxGroups.Name = "checkedListBox2"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 154
    $System_Drawing_Size.Width = 310
    $checkedListBoxGroups.Size = $System_Drawing_Size
    $checkedListBoxGroups.TabIndex = 15
    $checkedListBoxGroups.add_SelectedIndexChanged($handler_checkedListBox2_SelectedIndexChanged)
    
    $form1.Controls.Add($checkedListBoxGroups)
    
    $checkedListBoxCSVUsers.DataBindings.DefaultDataSourceUpdateMode = 0
    $checkedListBoxCSVUsers.FormattingEnabled = $True
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 41
    $System_Drawing_Point.Y = 186
    $checkedListBoxCSVUsers.Location = $System_Drawing_Point
    $checkedListBoxCSVUsers.Name = "checkedListBox1"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 154
    $System_Drawing_Size.Width = 310
    $checkedListBoxCSVUsers.Size = $System_Drawing_Size
    $checkedListBoxCSVUsers.TabIndex = 14
    
    $form1.Controls.Add($checkedListBoxCSVUsers)
    
    $label5.DataBindings.DefaultDataSourceUpdateMode = 0
    $label5.Font = New-Object System.Drawing.Font("Microsoft Sans Serif", 11.25, 0, 3, 0)
    
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 416
    $System_Drawing_Point.Y = 90
    $label5.Location = $System_Drawing_Point
    $label5.Name = "label5"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 22
    $System_Drawing_Size.Width = 336
    $label5.Size = $System_Drawing_Size
    $label5.TabIndex = 13
    $label5.Text = "Choisir l'emplacement des groupes (OU) :"
    $label5.add_Click($handler_label5_Click)
    
    $form1.Controls.Add($label5)
    
    $comboOUGroups.DataBindings.DefaultDataSourceUpdateMode = 0
    $comboOUGroups.FormattingEnabled = $True
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 416
    $System_Drawing_Point.Y = 116
    $comboOUGroups.Location = $System_Drawing_Point
    $comboOUGroups.Name = "comboBox3"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 21
    $System_Drawing_Size.Width = 300
    $comboOUGroups.Size = $System_Drawing_Size
    $comboOUGroups.TabIndex = 12
    $comboOUGroups.add_SelectedIndexChanged($comboOUGroups_SelectedIndexChanged)
    
    $form1.Controls.Add($comboOUGroups)
    
    
    $button1.DataBindings.DefaultDataSourceUpdateMode = 0
    $button1.Font = New-Object System.Drawing.Font("Microsoft Sans Serif", 9.75, 0, 3, 0)
    
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 214
    $System_Drawing_Point.Y = 116
    $button1.Location = $System_Drawing_Point
    $button1.Name = "button1"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 26
    $System_Drawing_Size.Width = 75
    $button1.Size = $System_Drawing_Size
    $button1.TabIndex = 3
    $button1.Text = "Ouvrir"
    $button1.UseVisualStyleBackColor = $True
    $button1.add_Click($handler_button1_Click)
    
    $form1.Controls.Add($button1)
    
    $textBoxCSVFile.DataBindings.DefaultDataSourceUpdateMode = 0
    $textBoxCSVFile.Enabled = $False
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 42
    $System_Drawing_Point.Y = 120
    $textBoxCSVFile.Location = $System_Drawing_Point
    $textBoxCSVFile.Name = "textBox1"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 20
    $System_Drawing_Size.Width = 160
    $textBoxCSVFile.Size = $System_Drawing_Size
    $textBoxCSVFile.TabIndex = 2
    
    $form1.Controls.Add($textBoxCSVFile)
    
    $label2.DataBindings.DefaultDataSourceUpdateMode = 0
    $label2.Font = New-Object System.Drawing.Font("Arial Narrow", 18, 1, 3, 0)
    
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 230
    $System_Drawing_Point.Y = 9
    $label2.Location = $System_Drawing_Point
    $label2.Name = "label2"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 52
    $System_Drawing_Size.Width = 318
    $label2.Size = $System_Drawing_Size
    $label2.TabIndex = 1
    $label2.Text = "Création d'utilisateurs AD"
    $label2.TextAlign = 32
    
    $form1.Controls.Add($label2)
    
    $label1.DataBindings.DefaultDataSourceUpdateMode = 0
    $label1.Font = New-Object System.Drawing.Font("Microsoft Sans Serif", 11.25, 0, 3, 0)
    
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 41
    $System_Drawing_Point.Y = 90
    $label1.Location = $System_Drawing_Point
    $label1.Name = "label1"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 23
    $System_Drawing_Size.Width = 336
    $label1.Size = $System_Drawing_Size
    $label1.TabIndex = 0
    $label1.Text = "Choisir le fichier texte (csv) :"
    $label1.add_Click($handler_label1_Click)
    
    $form1.Controls.Add($label1)
    
    #endregion Generated Form Code
    
    #Save the initial state of the form
    $InitialFormWindowState = $form1.WindowState
    #Init the OnLoad event to correct the initial state of the form
    $form1.add_Load($OnLoadForm_StateCorrection)
    #Show the Form
    $form1.ShowDialog() | Out-Null
    
    
} #End Function
#Call the Function
GenerateForm

    
  