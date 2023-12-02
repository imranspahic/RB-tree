import 'dart:io';

class Cvor<T extends Comparable<T>> {
  final T? vrijednost;
  late Cvor<T> roditelj;
  late Cvor<T> desno;
  late Cvor<T> lijevo;
  bool crven;

  bool isNill;

  Cvor(
    this.vrijednost, {
    this.crven = true,
    this.isNill = false,
  });

  @override
  operator ==(other) => other is Cvor && identical(this, other);

  @override
  int get hashCode => vrijednost.hashCode;

  String get boja => crven ? "R" : "B";

  @override
  String toString() {
    return "ključ:$vrijednost, boja:$boja, roditelj:(kljuc:${roditelj.vrijednost}, boja:${roditelj.boja}), lijevo:(kljuc:${lijevo.vrijednost}, boja:${lijevo.boja}), desno:(kljuc:${desno.vrijednost}, boja:${desno.boja})\n";
  }
}

class RBStablo<T extends Comparable<T>> {
  /// Čvor koji predstavlja korijen stabla (T.root)
  late Cvor<T> korijen;

  /// Čvor koji predstavlja null/nill vrijednost (T.nill)
  late Cvor<T> tnill;

  /// Inicijalizacija [tnill] i [korijen] čvorova.
  /// Korijen se inicijalno postavlja da bude [tnill].
  RBStablo() {
    tnill = Cvor<T>(
      null,
      isNill: true,
      crven: false,
    );
    tnill.lijevo = tnill;
    tnill.desno = tnill;
    tnill.roditelj = tnill;
    korijen = tnill;
  }

  /// Metoda koja obavlja lijevu rotaciju oko čvora [x].
  void LEFT_ROTATE(Cvor<T> x) {
    Cvor<T> y = x.desno;
    x.desno = y.lijevo;

    if (y.lijevo != tnill) {
      y.lijevo.roditelj = x;
    }

    y.roditelj = x.roditelj;

    if (x.roditelj == tnill) {
      korijen = y;
    } else if (x == x.roditelj.lijevo) {
      x.roditelj.lijevo = y;
    } else {
      x.roditelj.desno = y;
    }
    y.lijevo = x;
    x.roditelj = y;
  }

  /// Metoda koja obavlja desnu rotaciju oko čvora [x].
  /// Analogno [LEFT_ROTATE] jer je simetrično.
  void RIGHT_ROTATE(Cvor<T> y) {
    Cvor<T> x = y.lijevo;
    y.lijevo = x.desno;

    if (x.desno != tnill) {
      x.desno.roditelj = y;
    }

    x.roditelj = y.roditelj;

    if (y.roditelj == tnill) {
      korijen = x;
    } else if (y == y.roditelj.lijevo) {
      y.roditelj.lijevo = x;
    } else {
      y.roditelj.desno = x;
    }
    x.desno = y;
    y.roditelj = x;
  }

  /// Metoda koja obavlja umetanje čvora [z] u stablo.
  /// 1. Najprije se pronađe pozicija za umetanje u prvoj while petlji.
  /// 2. Vrši se umetanje čvora ažurirajući atribute
  /// 3. Poziva se [RB_INSERT_FIXUP] za očuvanje eventualno narušenih svojstava RB stabla.
  void RB_INSERT(Cvor<T> z) {
    Cvor<T> x = korijen;
    Cvor<T> y = tnill;
    while (x != tnill) {
      y = x;
      if (z.vrijednost!.compareTo(x.vrijednost!) < 0) {
        x = x.lijevo;
      } else {
        x = x.desno;
      }
    }
    z.roditelj = y;
    if (y == tnill) {
      korijen = z;
    } else if (z.vrijednost!.compareTo(y.vrijednost!) < 0) {
      y.lijevo = z;
    } else {
      y.desno = z;
    }
    z.lijevo = tnill;
    z.desno = tnill;
    z.crven = true;
    RB_INSERT_FIXUP(z);
  }

  /// Metoda koja obavlja korekciju radi očuvanja eventualno narušenih svojstava.
  /// Korekcija se obavlja kroz 4 slučaja (svi slučajevi nisu međusobno isključivi).
  void RB_INSERT_FIXUP(Cvor<T> z) {
    while (z.roditelj.crven) {
      if (z.roditelj == z.roditelj.roditelj.lijevo) {
        Cvor<T> y = z.roditelj.roditelj.desno;

        // Slučaj 1 - ujak/uncle čvora z je crvene boje.
        // U ovom slučaju vrši se korekcija boja za tri čvora i z čvor se pomjera ka vrhu.
        if (y.crven) {
          z.roditelj.crven = false;
          y.crven = false;
          z.roditelj.roditelj.crven = true;
          z = z.roditelj.roditelj;
        } else {
          // Slučaj 2 - z je desno dijete roditelja.
          // U ovom slučaju vrši se lijeva rotacija oko čvora z.
          if (z == z.roditelj.desno) {
            z = z.roditelj;
            LEFT_ROTATE(z);
          }

          // Slučaj 3.
          // U ovom slučaju vrši se korekcija boja i desna rotacija kao finalni korak.
          z.roditelj.crven = false;
          z.roditelj.roditelj.crven = true;
          RIGHT_ROTATE(z.roditelj.roditelj);
        }
      } else {
        Cvor<T>? y = z.roditelj.roditelj.lijevo;

        // Slučaj 1 - ujak/uncle čvora z je crvene boje.
        // U ovom slučaju vrši se korekcija boja za tri čvora i z čvor se pomjera ka vrhu.
        if (y.crven) {
          z.roditelj.crven = false;
          y.crven = false;
          z.roditelj.roditelj.crven = true;
          z = z.roditelj.roditelj;
        } else {
          // Slučaj 2 - z je lijevo dijete roditelja.
          // U ovom slučaju vrši se desna rotacija oko čvora z.
          if (z == z.roditelj.lijevo) {
            z = z.roditelj;
            RIGHT_ROTATE(z);
          }

          // Slučaj 3.
          // U ovom slučaju vrši se korekcija boja i lijeva rotacija kao finalni korak.
          z.roditelj.crven = false;
          z.roditelj.roditelj.crven = true;
          LEFT_ROTATE(z.roditelj.roditelj);
        }
      }
    }

    // Osiguranje da je korijen crn, svojstvo 1.
    korijen.crven = false;
  }

  /// Metoda koja obavlja zamjenju čvora [u] i čvora [v].
  /// Koristi se u procesu brisanja čvora.
  void RB_TRANSPLANT(Cvor<T> u, Cvor<T> v) {
    if (u.roditelj == tnill) {
      korijen = v;
    } else if (u == u.roditelj.lijevo) {
      u.roditelj.lijevo = v;
    } else {
      u.roditelj.desno = v;
    }
    v.roditelj = u.roditelj;
  }

  /// Metoda koja vraća najmanji čvor u lijevom podstablu čvoru [x].
  Cvor<T> TREE_MINIMUM(Cvor<T> x) {
    while (x.lijevo != tnill) {
      x = x.lijevo;
    }
    return x;
  }

  /// Metoda koja obavlja brisanje čvora za ključ [vrijednost].
  /// Na kraju brisanja poziva se [RB_DELETE_FIXUP] za korekciju eventualno narušenih svojstava RB stabla.
  bool RB_DELETE(T vrijednost) {
    Cvor<T> z = tnill;
    Cvor<T> x = korijen;
    while (true) {
      if (x == tnill) {
        break;
      }
      if (vrijednost.compareTo(x.vrijednost!) == 0) {
        z = x;
        break;
      } else if (vrijednost.compareTo(x.vrijednost!) < 0) {
        x = x.lijevo;
      } else {
        x = x.desno;
      }
    }

    // Vrijednost se ne nalazi u stablu
    if (z == tnill) {
      return false;
    }

    Cvor<T> y = z;
    bool yCrven = y.crven;

    if (z.lijevo == tnill) {
      x = z.desno;
      RB_TRANSPLANT(z, z.desno);
    } else if (z.desno == tnill) {
      x = z.lijevo;
      RB_TRANSPLANT(z, z.lijevo);
    } else {
      y = TREE_MINIMUM(z.desno);
      yCrven = y.crven;
      x = y.desno;
      if (y != z.desno) {
        RB_TRANSPLANT(y, y.desno);
        y.desno = z.desno;
        y.desno.roditelj = y;
      } else {
        x.roditelj = y;
      }
      RB_TRANSPLANT(z, y);
      y.lijevo = z.lijevo;
      y.lijevo.roditelj = y;
      y.crven = z.crven;
    }

    if (!yCrven) {
      RB_DELETE_FIXUP(x);
    }

    return true;
  }

  /// Metoda koja obavlja korekciju stabla nakon brisanja nekog čvora.
  void RB_DELETE_FIXUP(Cvor<T> x) {
    while (x != korijen && !x.crven) {
      if (x == x.roditelj.lijevo) {
        Cvor<T> w = x.roditelj.desno;

        // Slučaj 1.
        // Zamjena boja dva čvora i lijeva rotacija, nakon čega se trenutni čvor postavlja na sibling čvor.
        if (w.crven) {
          w.crven = false;
          x.roditelj.crven = true;
          LEFT_ROTATE(x.roditelj);
          w = x.roditelj.desno;
        }

        // Slučaj 2.
        // w čvor postaje crveni čvor.
        if (!w.lijevo.crven && !w.desno.crven) {
          w.crven = true;
          x = x.roditelj;
        } else {
          // Slučaj 3.
          // Zamjena boja dva čvora i desna rotacija.
          if (!w.desno.crven) {
            w.lijevo.crven = false;
            w.crven = true;
            RIGHT_ROTATE(w);
            w = x.roditelj.desno;
          }

          // Slučaj 4.
          // Zamjena boja i lijeva rotacija.
          w.crven = x.roditelj.crven;
          x.roditelj.crven = false;
          w.desno.crven = false;
          LEFT_ROTATE(x.roditelj);
          x = korijen;
        }
      } else {
        Cvor<T> w = x.roditelj.lijevo;

        // Slučaj 1.
        // Zamjena boja dva čvora i desna rotacija, nakon čega se trenutni čvor postavlja na sibling čvor.
        if (w.crven) {
          w.crven = false;
          x.roditelj.crven = true;
          RIGHT_ROTATE(x.roditelj);
          w = x.roditelj.lijevo;
        }

        // Slučaj 2.
        // w čvor postaje crveni čvor.
        if (!w.desno.crven && !w.lijevo.crven) {
          w.crven = true;
          x = x.roditelj;
        } else {
          // Slučaj 3.
          // Zamjena boja dva čvora i lijeva rotacija.
          if (!w.lijevo.crven) {
            w.desno.crven = false;
            w.crven = true;
            LEFT_ROTATE(w);
            w = x.roditelj.lijevo;
          }

          // Slučaj 4.
          // Zamjena boja i desna rotacija.
          w.crven = x.roditelj.crven;
          x.roditelj.crven = false;
          w.lijevo.crven = false;
          RIGHT_ROTATE(x.roditelj);
          x = korijen;
        }
      }
    }
    x.crven = false;
  }

  /// Metoda koja obavlja inorder ispisivanje stabla.
  /// Poziva [_inorder_print_recursive] za stvarni ispis.
  void INORDER_PRINT() {
    _inorder_print_recursive(korijen);
  }

  /// Pomćna rekurzivna metoda koja ispisuje inorder sadržaj stabla.
  void _inorder_print_recursive(Cvor<T> x) {
    if (x != tnill) {
      _inorder_print_recursive(x.lijevo);
      print(x);
      _inorder_print_recursive(x.desno);
    }
  }
}

void _umetanjeCvora(RBStablo stablo) {
  print("Umetanje novog čvora: ");
  print(" -> Unesite vrijednost: ");
  String? userInput = stdin.readLineSync();
  if (userInput == null) {
    print("Pogrešan unos. Pokušajte ponovo! ❌");
    return;
  }
  num? broj = num.tryParse(userInput);
  if (broj == null) {
    print("Pogrešan unos. Pokušajte ponovo! ❌");
    return;
  }
  stablo.RB_INSERT(Cvor<num>(broj));
  print(" -> Čvor sa ključem $broj dodan ✅");
}

void _brisanjeCvora(RBStablo stablo) {
  print("Brisanje čvora: ");
  print(" -> Unesite vrijednost: ");
  String? userInput = stdin.readLineSync();
  if (userInput == null) {
    print("Pogrešan unos. Pokušajte ponovo! ❌");
    return;
  }
  num? broj = num.tryParse(userInput);
  if (broj == null) {
    print("Pogrešan unos. Pokušajte ponovo! ❌");
    return;
  }
  bool status = stablo.RB_DELETE(broj);
  if (status) {
    print(" -> Čvor sa ključem $broj obrisan ✅");
  } else {
    print(" -> Čvor sa ključem $broj nije pronađen 🟡");
  }
}

void main() {
  RBStablo<num> stablo = RBStablo();
  while (true) {
    print("--------------------------");
    print("Meni:");
    print("1. Umetanje novog čvora");
    print("2. INORDER ispis čvorova na ekran");
    print("3. Brisanje čvora");
    print("4. Izlaz");
    print("--------------------------");

    stdout.write("Izaberite opciju (1, 2, 3 ili 4): ");
    String? userInput = stdin.readLineSync();

    if (userInput == null) {
      print("Pogrešan unos. Pokušajte ponovo! ❌");
      continue;
    }

    switch (userInput) {
      case '1':
        _umetanjeCvora(stablo);
        break;
      case '2':
        stablo.INORDER_PRINT();
        break;
      case '3':
        _brisanjeCvora(stablo);
        break;
      case '4':
        print("Izlazak iz programa ...");
        return;
      default:
        print("Pogrešan unos. Pokušajte ponovo! ❌");
        break;
    }
  }
}
