#!/bin/sh

export LANGUAGE="C";
export LC_ALL="C";
export LC_CTYPE="C";
export LANG="fr";

echo "Launched on "
date 
perl ./script/make-album.pl -l -V

perl ./script/make-album.pl -l 1 Aulnay/ fr fr:en:es:it
perl ./script/make-album.pl -l 2 Brousse/ fr fr:en:es:it
perl ./script/make-album.pl -l 3 Caen/ fr fr:en:es:it
perl ./script/make-album.pl -l 4 Chartres/ fr fr:en:es:it
perl ./script/make-album.pl -l 5 Fontdouce/ fr fr:en:es:it
perl ./script/make-album.pl -l 6 Chauvigny/ fr fr:en:es:it
perl ./script/make-album.pl -l 7 Citeaux/ fr fr:en:es:it
perl ./script/make-album.pl -l 11 Moncel/ fr fr:en:es:it
perl ./script/make-album.pl -l 12 Civray/ fr fr:en:es:it
perl ./script/make-album.pl -l 15 Dampierre/ fr fr:en:es:it
perl ./script/make-album.pl -l 16 Ercuis/ fr fr:en:es:it
if [ ! -d Maillezais ]; then
        mkdir Maillezais
        chmod 0755 Maillezais
fi
perl ./script/make-album.pl -l 17 Maillezais/Abbaye/ fr fr:en:es:it
perl ./script/make-album.pl -l 18 Marestay/ fr fr:en:es:it
perl ./script/make-album.pl -l 19 Matha/ fr fr:en:es:it
perl ./script/make-album.pl -l 20 Maillezais/St_Nicolas/ fr fr:en:es:it
perl ./script/make-album.pl -l 21 Montmorillon/ fr fr:en:es:it
if [ ! -d Paris ]; then
        mkdir Paris
        chmod 0755 Paris
fi
perl ./script/make-album.pl -l 22 Paris/Notre_Dame_de_Paris/ fr fr:en:es:it
perl ./script/make-album.pl -l 26 Benet/ fr fr:en:es:it
perl ./script/make-album.pl -l 27 Lusignan/ fr fr:en:es:it
perl ./script/make-album.pl -l 28 Maille/ fr fr:en:es:it
perl ./script/make-album.pl -l 29 Nouaille_Mauperthuis/ fr fr:en:es:it
perl ./script/make-album.pl -l 30 Poitiers/ fr fr:en:es:it
perl ./script/make-album.pl -l 31 Paris/Sainte_Chapelle/ fr fr:en:es:it
perl ./script/make-album.pl -l 32 Precy/ fr fr:en:es:it
perl ./script/make-album.pl -l 33 Saint_Leu/ fr fr:en:es:it
perl ./script/make-album.pl -l 34 Royaumont/ fr fr:en:es:it
perl ./script/make-album.pl -l 35 Senlis/ fr fr:en:es:it
perl ./script/make-album.pl -l 36 Vezelay/ fr fr:en:es:it
perl ./script/make-album.pl -l 38 Provins/ fr fr:en:es:it
perl ./script/make-album.pl -l 39 Reims/ fr fr:en:es:it
if [ ! -d Saintes ]; then
        mkdir Saintes
        chmod 0755 Saintes
fi
perl ./script/make-album.pl -l 40 Saintes/ fr fr:en:es:it
perl ./script/make-album.pl -l 41 Saint_Savin/ fr fr:en:es:it
perl ./script/make-album.pl -l 42 Senanque/ fr fr:en:es:it
perl ./script/make-album.pl -l 43 Silvacane/ fr fr:en:es:it
perl ./script/make-album.pl -l 44 Sylvanes/ fr fr:en:es:it
perl ./script/make-album.pl -l 45 Thoronet/ fr fr:en:es:it
perl ./script/make-album.pl -l 46 Saint_Mande_sur_Bredoire/ fr fr:en:es:it
perl ./script/make-album.pl -l 48 Saint_Benoit_sur_Loire/ fr fr:en:es:it
perl ./script/make-album.pl -l 49 Nieul/ fr fr:en:es:it
perl ./script/make-album.pl -l 50 Vouvant/ fr fr:en:es:it
perl ./script/make-album.pl -l 51 St_Eutrope_Eglise_Basse/ fr fr:en:es:it
perl ./script/make-album.pl -l 52 St_Eutrope_Eglise_Haute/ fr fr:en:es:it
perl ./script/make-album.pl -l 53 Beaune/ fr fr:en:es:it
perl ./script/make-album.pl -l 54 Couvertoirade/ fr fr:en:es:it
perl ./script/make-album.pl -l 55 Paris/Saint_Eustache/ fr fr:en:es:it
perl ./script/make-album.pl -l 56 StAmanddeColy/ fr fr:en:es:it
perl ./script/make-album.pl -l 57 Boschaud/ fr fr:en:es:it
perl ./script/make-album.pl -l 58 Cadouin/ fr fr:en:es:it
perl ./script/make-album.pl -l 60 Paunat/ fr fr:en:es:it
perl ./script/make-album.pl -l 61 Brantome/ fr fr:en:es:it
perl ./script/make-album.pl -l 62 Cenac/ fr fr:en:es:it
perl ./script/make-album.pl -l 63 SaintLeonsurVezere/ fr fr:en:es:it
perl ./script/make-album.pl -l 65 Thiviers/ fr fr:en:es:it
perl ./script/make-album.pl -l 66 Audrix/ fr fr:en:es:it
perl ./script/make-album.pl -l 67 Auvers/ fr fr:en:es:it
perl ./script/make-album.pl -l 68 Beauvais/ fr fr:en:es:it
perl ./script/make-album.pl -l 69 Belves/ fr fr:en:es:it
perl ./script/make-album.pl -l 70 Maubuisson/ fr fr:en:es:it
perl ./script/make-album.pl -l 72 Chancelade/ fr fr:en:es:it
perl ./script/make-album.pl -l 73 Merlande/ fr fr:en:es:it
perl ./script/make-album.pl -l 74 Mery/ fr fr:en:es:it
perl ./script/make-album.pl -l 75 Monpazier/ fr fr:en:es:it
perl ./script/make-album.pl -l 76 Tremolat/ fr fr:en:es:it
perl ./script/make-album.pl -l 77 StGermerdeFly/ fr fr:en:es:it
perl ./script/make-album.pl -l 85 Melle/ fr fr:en:es:it
perl ./script/make-album.pl -l 86 Aiguebelle/ fr fr:en:es:it
if [ ! -d Arles ]; then
        mkdir Arles
        chmod 0755 Arles
fi
if [ ! -d  Arles/StTrophime ]; then
        mkdir  Arles/StTrophime
        chmod 0755  Arles/StTrophime
fi
perl ./script/make-album.pl -l 87 Arles/StTrophime/Facade/ fr fr:en:es:it
perl ./script/make-album.pl -l 88 Arles/StTrophime/Eglise/ fr fr:en:es:it
perl ./script/make-album.pl -l 89 Arles/StTrophime/Cloitre/ fr fr:en:es:it
perl ./script/make-album.pl -l 90 Arles/StHonorat/ fr fr:en:es:it
perl ./script/make-album.pl -l 92 Montmajour/ fr fr:en:es:it
perl ./script/make-album.pl -l 93 LaGardeAdhemar/ fr fr:en:es:it
perl ./script/make-album.pl -l 94 SaintPaultroischateaux/ fr fr:en:es:it
perl ./script/make-album.pl -l 95 VaisonLaRomaine/ fr fr:en:es:it
perl ./script/make-album.pl -l 96 Montfavet/ fr fr:en:es:it
perl ./script/make-album.pl -l 97 Boiscommun/ fr fr:en:es:it
perl ./script/make-album.pl -l 98 Le_Lys/ fr fr:en:es:it
if [ ! -d  Avignon ]; then
        mkdir Avignon
        chmod 0755 Avignon
fi
perl ./script/make-album.pl -l 99 Avignon/Palais_des_Papes/ fr fr:en:es:it
perl ./script/make-album.pl -l 100 Avignon/SaintBenezet/ fr fr:en:es:it
perl ./script/make-album.pl -l 101 Uzes/ fr fr:en:es:it
perl ./script/make-album.pl -l 102 Saint_Front/ fr fr:en:es:it
perl ./script/make-album.pl -l 103 Sarlat/ fr fr:en:es:it
perl ./script/make-album.pl -l 104 Sainte_Alvere/ fr fr:en:es:it
if [ ! -d  Perigueux ]; then
        mkdir Perigueux
        chmod 0755 Perigueux
fi
perl ./script/make-album.pl -l 105 Perigueux/StEtienne/ fr fr:en:es:it
if [ ! -d Suisse ]; then
        mkdir Suisse
        chmod 0755 Suisse
fi
perl ./script/make-album.pl -l 106 Suisse/Maigrauge/ fr fr:en:es:it
perl ./script/make-album.pl -l 109 Suisse/Romainmotier/ fr fr:en:es:it
if [ ! -d Ourscamp ]; then
        mkdir Ourscamp
        chmod 0755 Ourscamp
fi
perl ./script/make-album.pl -l 108 Ourscamp/Maison/ fr fr:en:es:it
perl ./script/make-album.pl -l 110 Charroux/ fr fr:en:es:it
perl ./script/make-album.pl -l 112 Chatain/ fr fr:en:es:it
perl ./script/make-album.pl -l 114 Civaux/ fr fr:en:es:it
perl ./script/make-album.pl -l 115 Epau/ fr fr:en:es:it
perl ./script/make-album.pl -l 116 Genouille/ fr fr:en:es:it
perl ./script/make-album.pl -l 117 LaReau/ fr fr:en:es:it
perl ./script/make-album.pl -l 118 LeMans/ fr fr:en:es:it
perl ./script/make-album.pl -l 119 StMauricelaClouere/ fr fr:en:es:it
perl ./script/make-album.pl -l 120 StPierredExideuil/ fr fr:en:es:it
perl ./script/make-album.pl -l 121 Usson/ fr fr:en:es:it
perl ./script/make-album.pl -l 122 Conflans/ fr fr:en:es:it
perl ./script/make-album.pl -l 123 Isle-sur-Sorgue/ fr fr:en:es:it
perl ./script/make-album.pl -l 124 Morienval/ fr fr:en:es:it
perl ./script/make-album.pl -l 125 Pontigny/ fr fr:en:es:it
perl ./script/make-album.pl -l 126 Seignelay/ fr fr:en:es:it
perl ./script/make-album.pl -l 127 Clos-Vougeot/ fr fr:en:es:it
perl ./script/make-album.pl -l 128 Chatou/ fr fr:en:es:it
perl ./script/make-album.pl -l 129 Poissy/ fr fr:en:es:it
perl ./script/make-album.pl -l 130 Suisse/Grandson/ fr fr:en:es:it
perl ./script/make-album.pl -l 131 Chateauneuf-Pouilly/  fr fr:en:es:it
perl ./script/make-album.pl -l 132 Bougival/ fr fr:en:es:it
perl ./script/make-album.pl -l 133 Gimeux/ fr fr:en:es:it
perl ./script/make-album.pl -l 137 Ganagobie/ fr fr:en:es:it
perl ./script/make-album.pl -l 138 Frejus/ fr fr:en:es:it
perl ./script/make-album.pl -l 139 Chatres/ fr fr:en:es:it
perl ./script/make-album.pl -l 140 Tournus/ fr fr:en:es:it
perl ./script/make-album.pl -l 141 Airvault/ fr fr:en:es:it
perl ./script/make-album.pl -l 142 Brancion/ fr fr:en:es:it
perl ./script/make-album.pl -l 143 Chapaize/ fr fr:en:es:it
perl ./script/make-album.pl -l 144 Autun/ fr fr:en:es:it
perl ./script/make-album.pl -l 145 Cluny/ fr fr:en:es:it
perl ./script/make-album.pl -l 146 Fontenay/ fr fr:en:es:it
perl ./script/make-album.pl -l 147 Angouleme/ fr fr:en:es:it
perl ./script/make-album.pl -l 148 Le_val/ fr fr:en:es:it
perl ./script/make-album.pl -l 150 Mareil-Marly/ fr fr:en:es:it
perl ./script/make-album.pl -l 151 Saint_Generoux/ fr fr:en:es:it
perl ./script/make-album.pl -l 152 Saint_Jouin_de_Marnes/ fr fr:en:es:it
perl ./script/make-album.pl -l 153 Jalogny/ fr fr:en:es:it
perl ./script/make-album.pl -l 154 Rians/ fr fr:en:es:it
perl ./script/make-album.pl -l 155 Ruffec/ fr fr:en:es:it
perl ./script/make-album.pl -l 156 Louveciennes/ fr fr:en:es:it
perl ./script/make-album.pl -l 157 Saint_Denis/ fr fr:en:es:it
perl ./script/make-album.pl -l 158 Treves/ fr fr:en:es:it
perl ./script/make-album.pl -l 159 Chenehutte/ fr fr:en:es:it
perl ./script/make-album.pl -l 160 Candes/ fr fr:en:es:it
perl ./script/make-album.pl -l 161 Port_Royal/ fr fr:en:es:it
perl ./script/make-album.pl -l 162 Gilocourt/ fr fr:en:es:it
perl ./script/make-album.pl -l 163 Bethancourt/ fr fr:en:es:it
perl ./script/make-album.pl -l 164 Suisse/Giornico/ fr fr:en:es:it
perl ./script/make-album.pl -l 165 Vaux_de_Cernay/ fr fr:en:es:it
perl ./script/make-album.pl -l 166 Cunault/ fr fr:en:es:it
perl ./script/make-album.pl -l 167 Fontevraud/ fr fr:en:es:it
if [ ! -d Etampes ]; then
        mkdir Etampes
        chmod 0755 Etampes
fi
perl ./script/make-album.pl -l 168 Etampes/Notre_Dame_du_Fort/ fr fr:en:es:it
perl ./script/make-album.pl -l 169 Etampes/Saint_Martin/ fr fr:en:es:it
perl ./script/make-album.pl -l 170 Etampes/Saint_Basile/ fr fr:en:es:it
perl ./script/make-album.pl -l 171 Vaucelles/ fr fr:en:es:it
perl ./script/make-album.pl -l 172 Blesle/ fr fr:en:es:it
perl ./script/make-album.pl -l 173 StPaulien/ fr fr:en:es:it
perl ./script/make-album.pl -l 174 Mailhat/ fr fr:en:es:it
perl ./script/make-album.pl -l 175 Brioude/ fr fr:en:es:it
perl ./script/make-album.pl -l 176 Issoire/ fr fr:en:es:it
perl ./script/make-album.pl -l 177 Mozac/ fr fr:en:es:it
perl ./script/make-album.pl -l 178 Bourbon/ fr fr:en:es:it
perl ./script/make-album.pl -l 179 La_Pree/ fr fr:en:es:it
perl ./script/make-album.pl -l 180 Royat/ fr fr:en:es:it
perl ./script/make-album.pl -l 181 Orcival/ fr fr:en:es:it
perl ./script/make-album.pl -l 182 Ennezat/ fr fr:en:es:it
if [ ! -d Clermont ]; then
        mkdir Clermont
        chmod 0755 Clermont
fi
perl ./script/make-album.pl -l 183 Clermont/ND_Port/ fr fr:en:es:it
perl ./script/make-album.pl -l 184 Saint_Nectaire/ fr fr:en:es:it
perl ./script/make-album.pl -l 185 Saint_Saturnin/ fr fr:en:es:it
perl ./script/make-album.pl -l 186 Ineuil/ fr fr:en:es:it
perl ./script/make-album.pl -l 187 Ygrande/ fr fr:en:es:it
if [ ! -d Le_Puy ]; then
        mkdir Le_Puy
        chmod 0755 Le_Puy
fi
perl ./script/make-album.pl -l 188 Le_Puy/Notre_Dame/ fr fr:en:es:it
perl ./script/make-album.pl -l 189 Le_Puy/Saint_Michel/ fr fr:en:es:it
perl ./script/make-album.pl -l 190 Saint-Julien-Chapteuil/ fr fr:en:es:it
perl ./script/make-album.pl -l 191 Noirlac/ fr fr:en:es:it
perl ./script/make-album.pl -l 192 Lavaudieu/ fr fr:en:es:it
perl ./script/make-album.pl -l 193 Bourges/ fr fr:en:es:it
perl ./script/make-album.pl -l 194 Lerins/ fr fr:en:es:it
perl ./script/make-album.pl -l 195 Clermont/ND_Assomption/ fr fr:en:es:it
perl ./script/make-album.pl -l 196 Bayeux/ fr fr:en:es:it
perl ./script/make-album.pl -l 197 Saint-Martin-de-Boscherville/ fr fr:en:es:it
perl ./script/make-album.pl -l 198 Chaalis/ fr fr:en:es:it
perl ./script/make-album.pl -l 199 Cerisy-la-Foret/ fr fr:en:es:it
perl ./script/make-album.pl -l 200 Allichamps/ fr fr:en:es:it
perl ./script/make-album.pl -l 201 Rucqueville/ fr fr:en:es:it
perl ./script/make-album.pl -l 202 SaintGabrielBrecy/ fr fr:en:es:it
perl ./script/make-album.pl -l 203 Orgeval/ fr fr:en:es:it
perl ./script/make-album.pl -l 204 Feucherolles/ fr fr:en:es:it
perl ./script/make-album.pl -l 205 Carennac/ fr fr:en:es:it
perl ./script/make-album.pl -l 207 Berze-la-Ville/ fr fr:en:es:it
perl ./script/make-album.pl -l 208 Montceaux_l_Etoile/ fr fr:en:es:it
perl ./script/make-album.pl -l 209 Neuilly-en-Donjon/ fr fr:en:es:it
perl ./script/make-album.pl -l 210 Charlieu/Saint-Fortunat/ fr fr:en:es:it
perl ./script/make-album.pl -l 228 Charlieu/Cordeliers/ fr fr:en:es:it
perl ./script/make-album.pl -l 211 Anzy-le-Duc/ fr fr:en:es:it
perl ./script/make-album.pl -l 212 Baron/ fr fr:en:es:it
perl ./script/make-album.pl -l 213 Mazille/ fr fr:en:es:it
perl ./script/make-album.pl -l 214 Varenne-l-Arconce/ fr fr:en:es:it
perl ./script/make-album.pl -l 215 Amiens/ fr fr:en:es:it
perl ./script/make-album.pl -l 216 Iguerande/ fr fr:en:es:it
perl ./script/make-album.pl -l 217 Massy/ fr fr:en:es:it
perl ./script/make-album.pl -l 218 Mont-Saint-Vincent/ fr fr:en:es:it
perl ./script/make-album.pl -l 219 Saint-Germain-en-Brionnais/ fr fr:en:es:it
perl ./script/make-album.pl -l 220 Semur-en-Brionnais/ fr fr:en:es:it
perl ./script/make-album.pl -l 221 Saint-Julien-de-Jonzy/ fr fr:en:es:it
perl ./script/make-album.pl -l 222 Paray-le-Monial/ fr fr:en:es:it
perl ./script/make-album.pl -l 223 Perrecy-les-Forges/ fr fr:en:es:it
perl ./script/make-album.pl -l 224 Gourdon/ fr fr:en:es:it
perl ./script/make-album.pl -l 225 Cervon/ fr fr:en:es:it
perl ./script/make-album.pl -l 226 Donzy-le-Pre/ fr fr:en:es:it
perl ./script/make-album.pl -l 227 Saint-Reverien/ fr fr:en:es:it
perl ./script/make-album.pl -l 228 Charlieu/Cordeliers/ fr fr:en:es:it
perl ./script/make-album.pl -l 229 Coulgens/ fr fr:en:es:it
perl ./script/make-album.pl -l 230 La-Couronne/ fr fr:en:es:it
perl ./script/make-album.pl -l 231 Puymoyen/ fr fr:en:es:it
perl ./script/make-album.pl -l 232 Roullet/ fr fr:en:es:it
perl ./script/make-album.pl -l 233 Saulieu/ fr fr:en:es:it
perl ./script/make-album.pl -l 234 Saint_Raphael/ fr fr:en:es:it
perl ./script/make-album.pl -l 235 Roullet-Saint_Estephe/ fr fr:en:es:it
perl ./script/make-album.pl -l 236 Saint-Michel-d-Entraygues/ fr fr:en:es:it
perl ./script/make-album.pl -l 237 Sainte-Colombe/ fr fr:en:es:it
perl ./script/make-album.pl -l 238 Trois-Palis/ fr fr:en:es:it
perl ./script/make-album.pl -l 239 Saint-Loup-de-Naud/ fr fr:en:es:it
perl ./script/make-album.pl -l 240 Jumiege/ fr fr:en:es:it
perl ./script/make-album.pl -l 241 Mont-Saint-Michel/ fr fr:en:es:it
perl ./script/make-album.pl -l 242 Bagnizeau/ fr fr:en:es:it
if [ ! -d Montreuil-sur-Mer ]; then
        mkdir Montreuil-sur-Mer
        chmod 0755 Montreuil-sur-Mer
fi
perl ./script/make-album.pl -l 243 Montreuil-sur-Mer/Saint-Saulve/ fr fr:en:es:it
perl ./script/make-album.pl -l 244 Voulgezac/ fr fr:en:es:it
perl ./script/make-album.pl -l 245 Varaize/ fr fr:en:es:it
perl ./script/make-album.pl -l 246 Lesterps/ fr fr:en:es:it
perl ./script/make-album.pl -l 247 Solignac/ fr fr:en:es:it
perl ./script/make-album.pl -l 248 Aubiac/ fr fr:en:es:it
perl ./script/make-album.pl -l 249 Faye/ fr fr:en:es:it
perl ./script/make-album.pl -l 250 Frespech/ fr fr:en:es:it
perl ./script/make-album.pl -l 251 Gensac-la-Pallue/ fr fr:en:es:it
perl ./script/make-album.pl -l 252 Saint-Maurin/ fr fr:en:es:it
perl ./script/make-album.pl -l 253 Sainte-Livrade/ fr fr:en:es:it
if [ ! -d Moissac ]; then
        mkdir Moissac
        chmod 0755 Moissac
fi
perl ./script/make-album.pl -l 254 Moissac/Saint-Martin/ fr fr:en:es:it
perl ./script/make-album.pl -l 255 Layrac/ fr fr:en:es:it
perl ./script/make-album.pl -l 256 Le-Bugat/ fr fr:en:es:it
perl ./script/make-album.pl -l 257 Saint-Gilles-du-Gard/ fr fr:en:es:it
perl ./script/make-album.pl -l 258 Moissac/Saint-Pierre/ fr fr:en:es:it
perl ./script/make-album.pl -l 259 Moissac/Saint-Pierre-Cloitre/ fr fr:en:es:it
perl ./script/make-album.pl -l 260 Agen/ fr fr:en:es:it
perl ./script/make-album.pl -l 261 Moirax/ fr fr:en:es:it
perl ./script/make-album.pl -l 262 Paris/Saint-Germain-des-Pres/ fr fr:en:es:it
perl ./script/make-album.pl -l 263 Gisors/ fr fr:en:es:it
perl ./script/make-album.pl -l 264 Plaimpied-Givaudins/ fr fr:en:es:it
perl ./script/make-album.pl -l 265 Avord/ fr fr:en:es:it
perl ./script/make-album.pl -l 266 Jussy-Champagne/ fr fr:en:es:it
perl ./script/make-album.pl -l 267 Blet/ fr fr:en:es:it
perl ./script/make-album.pl -l 268 Dun-sur-Auron/ fr fr:en:es:it
perl ./script/make-album.pl -l 269 Charite-sur-Loire/ fr fr:en:es:it
if [ ! -d Cahors ]; then
        mkdir Cahors
        chmod 0755 Cahors
fi
perl ./script/make-album.pl -l 270 Cahors/Saint_Etienne/ fr fr:en:es:it
perl ./script/make-album.pl -l 271 Cahors/Valentre/ fr fr:en:es:it
perl ./script/make-album.pl -l 272 Lacour/ fr fr:en:es:it
if [ ! -d Lyon ]; then
        mkdir Lyon
        chmod 0755 Lyon
fi
perl ./script/make-album.pl -l 273 Lyon/Saint-Jean-Baptiste/ fr fr:en:es:it
if [ ! -d Ille-sur-Tet]; then
        mkdir Ille-sur-Tet
        chmod 0755 Ille-sur-Tet
fi
perl ./script/make-album.pl -l 274 Ille-sur-Tet/Casenoves/ fr fr:en:es:it
perl ./script/make-album.pl -l 275 Fenollar/ fr fr:en:es:it
perl ./script/make-album.pl -l 276 Marcevol/ fr fr:en:es:it
perl ./script/make-album.pl -l 277 Cabestany/ fr fr:en:es:it
perl ./script/make-album.pl -l 278 Corneilla-de-Conflent/ fr fr:en:es:it
perl ./script/make-album.pl -l 279 Souillac/ fr fr:en:es:it
perl ./script/make-album.pl -l 280 Saint-Genis-des-fontaines/ fr fr:en:es:it
perl ./script/make-album.pl -l 281 Fontfroide/ fr fr:en:es:it
perl ./script/make-album.pl -l 282 Saint-Michel-de-Cuixa/ fr fr:en:es:it
perl ./script/make-album.pl -l 283 Serrabone/ fr fr:en:es:it
perl ./script/make-album.pl -l 284 Saint-Martin-du-Canigou/ fr fr:en:es:it
perl ./script/make-album.pl -l 285 Lille/ fr fr:en:es:it
perl ./script/make-album.pl -l 286 San-Feliu-d-Amont/ fr fr:en:es:it
perl ./script/make-album.pl -l 287 Fenioux/ fr fr:en:es:it
if [ ! -d Corse]; then
        mkdir Corse
        chmod 0755 Corse
fi
perl ./script/make-album.pl -l 288 Corse/Canonica/ fr fr:en:es:it
perl ./script/make-album.pl -l 289 Corse/Erbalunga/ fr fr:en:es:it
perl ./script/make-album.pl -l 290 Corse/Carbini/ fr fr:en:es:it
perl ./script/make-album.pl -l 291 Corse/Tallano/ fr fr:en:es:it
perl ./script/make-album.pl -l 292 Corse/Castirla/ fr fr:en:es:it
perl ./script/make-album.pl -l 293 Corse/Murato/ fr fr:en:es:it
perl ./script/make-album.pl -l 294 Corse/Sisco/ fr fr:en:es:it
perl ./script/make-album.pl -l 295 Corse/Sermano/ fr fr:en:es:it
perl ./script/make-album.pl -l 296 Corse/Aregno/ fr fr:en:es:it
perl ./script/make-album.pl -l 297 Corse/Bonifacio/ fr fr:en:es:it
perl ./script/make-album.pl -l 298 Corse/Cambia/ fr fr:en:es:it
perl ./script/make-album.pl -l 299 Corse/Canari/ fr fr:en:es:it
perl ./script/make-album.pl -l 300 Corse/Castellare-di-Casinca/ fr fr:en:es:it
perl ./script/make-album.pl -l 301 Corse/Favalello/ fr fr:en:es:it
perl ./script/make-album.pl -l 302 Corse/Figari/ fr fr:en:es:it
perl ./script/make-album.pl -l 303 Corse/Lumio/ fr fr:en:es:it
perl ./script/make-album.pl -l 304 Corse/Mariana/ fr fr:en:es:it
perl ./script/make-album.pl -l 305 Corse/Montegrosso/ fr fr:en:es:it
perl ./script/make-album.pl -l 306 Corse/Olcani/ fr fr:en:es:it
perl ./script/make-album.pl -l 307 Corse/Quenza/ fr fr:en:es:it
perl ./script/make-album.pl -l 308 Corse/Saint-Florent/ fr fr:en:es:it
perl ./script/make-album.pl -l 309 Corse/Santa-Maria-Figaniella/ fr fr:en:es:it
perl ./script/make-album.pl -l 310 Corse/Santa-Maria-Assunta-Sicche/ fr fr:en:es:it
perl ./script/make-album.pl -l 311 Corse/Valle-di-Campoloro/ fr fr:en:es:it
perl ./script/make-album.pl -l 312 Cruas/ fr fr:en:es:it
perl ./script/make-album.pl -l 313 Sainte-Croix-de-Beaumont/ fr fr:en:es:it
perl ./script/make-album.pl -l 314 Champagne/ fr fr:en:es:it
perl ./script/make-album.pl -l 315 LaSauveMajeure/ fr fr:en:es:it
perl ./script/make-album.pl -l 316 Lyon/Ainey/ fr fr:en:es:it
perl ./script/make-album.pl -l 317 Brinay/ fr fr:en:es:it
perl ./script/make-album.pl -l 318 Saint_Emilion/ fr fr:en:es:it
perl ./script/make-album.pl -l 319 Petit_Palais/ fr fr:en:es:it
perl ./script/make-album.pl -l 321 Berzy-le-sec/ fr fr:en:es:it
perl ./script/make-album.pl -l 323 La-Celle/ fr fr:en:es:it
perl ./script/make-album.pl -l 325 Saint-Jeanvrin/ fr fr:en:es:it
perl ./script/make-album.pl -l 326 Saint-Junien/ fr fr:en:es:it
perl ./script/make-album.pl -l 327 La-Croix-sur-Ourcq/ fr fr:en:es:it
perl ./script/make-album.pl -l 328 Nohan-Vic/ fr fr:en:es:it
perl ./script/make-album.pl -l 329 Andlau/ fr fr:en:es:it
perl ./script/make-album.pl -l 330 Epfig/ fr fr:en:es:it
perl ./script/make-album.pl -l 331 Norvege/Gol/ fr fr:en:es:it
perl ./script/make-album.pl -l 332 Espagne/Silos/ fr fr:en:es:it
perl ./script/make-album.pl -l 333 Saint-Chef/ fr fr:en:es:it
perl ./script/make-album.pl -l 334 Suisse/Zillis/ fr fr:en:es:it
perl ./script/make-album.pl -l 335 Espalion/ fr fr:en:es:it
perl ./script/make-album.pl -l 336 Conques/ fr fr:en:es:it
perl ./script/make-album.pl -l 337 Saint-Guilhem/ fr fr:en:es:it
if [ ! -d Reims/Saint-Remy]; then
        mkdir Reims/Saint-Remy
        chmod 0755 Reims/Saint-Remy
fi
perl ./script/make-album.pl -l 342 Reims/Saint-Remy/ fr fr:en:es:it
perl ./script/make-album.pl -l 343 Strasbourg/ fr fr:en:es:it
perl ./script/make-album.pl -l 344 Ydes/ fr fr:en:es:it
perl ./script/make-album.pl -l 345 Cormeilles-en-Vexin/ fr fr:en:es:it
perl ./script/make-album.pl -l 346 Selestat/ fr fr:en:es:it
perl ./script/make-album.pl -l 347 Rosheim/ fr fr:en:es:it
perl ./script/make-album.pl -l 348 Suisse/Payerne/ fr fr:en:es:it
perl ./script/make-album.pl -l 349 Vienne/ fr fr:en:es:it
perl ./script/make-album.pl -l 350 Marmoutier/ fr fr:en:es:it
perl ./script/make-album.pl -l 351 Ottmarsheim/ fr fr:en:es:it
perl ./script/make-album.pl -l 352 Eschau/ fr fr:en:es:it
perl ./script/make-album.pl -l 353 Lassouts/ fr fr:en:es:it
perl ./script/make-album.pl -l 354 Digne/ fr fr:en:es:it
perl ./script/make-album.pl -l 355 Saint-Thierry/ fr fr:en:es:it
perl ./script/make-album.pl -l 356 Souvigny/ fr fr:en:es:it
if [ ! -d Italia ]; then
        mkdir Italia
        chmod 0755 Italia
fi
if [ ! -d Italia/Firenze ]; then
        mkdir Italia/Firenze
        chmod 0755 Italia/Firenze
fi
perl ./script/make-album.pl -l 357 Italia/Firenze/SanMiniatoAlMonte/ fr fr:en:es:it
if [ ! -d Italia/Milano ]; then
        mkdir Italia/Milano
        chmod 0755 Italia/Milano
fi
perl ./script/make-album.pl -l 358 Italia/Milano/SantAmbrogio/ fr fr:en:es:it
if [ ! -d Italia/Como ]; then
        mkdir Italia/Como
        chmod 0755 Italia/Como
fi
perl ./script/make-album.pl -l 359 Italia/Como/SantAbbondio/ fr fr:en:es:it
if [ ! -d Italia/Chiusdino ]; then
        mkdir Italia/Chiusdino
        chmod 0755 Italia/Chiusdino
fi
perl ./script/make-album.pl -l 360 Italia/Chiusdino/SanGalgano/ fr fr:en:es:it
perl ./script/make-album.pl -l 361 Italia/Murano/SantiMaria_Donato/ fr fr:en:es:it
perl ./script/make-album.pl -l 362 Italia/Ravenna/San_Vital/ fr fr:en:es:it
perl ./script/make-album.pl -l 363 Italia/Lucca/SanMartino/ fr fr:en:es:it
perl ./script/make-album.pl -l 364 Italia/Firenze/Baptistere/ fr fr:en:es:it
perl ./script/make-album.pl -l 365 Italia/Verona/SanZeno/ fr fr:en:es:it

